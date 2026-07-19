# ML Serving Stack

GPU allocation for model serving on the future ML platform fork.

## The Problem

Karpenter provisions GPU nodes sized to satisfy a pod's `nvidia.com/gpu: 1` request. Kubernetes treats this request as one whole physical GPU, not a fraction. For large LLMs this often means a 40 to 80GB GPU, and the pod gets the entire device regardless of how much of it the model actually uses. There is no built-in way to pack multiple models onto a fraction of a single GPU, so idle capacity goes to waste.

## Options Considered

**KAI Scheduler** is a Kubernetes scheduler plugin for fractional GPU allocation and gang scheduling. It is not a serving framework, so it can pair with either KServe or Ray Serve.

**KServe** is declarative, CRD-based model serving. It supports classical ML runtimes through `InferenceService` and vLLM through the newer `LLMInferenceService`.

**KubeRay and Ray Serve** offer a Python-first deployment model with native fractional GPU requests and first-party KAI Scheduler support. The cost is an imperative deployment config that breaks from a GitOps pattern, and a second cluster autoscaler to operate alongside Karpenter.

**llm-d** is the distributed serving layer underneath KServe's `LLMInferenceService`. Its Endpoint Picker (EPP) provides KV-cache-aware and prefix-aware routing, used by `LLMInferenceService` regardless of deployment mode. Its other piece, disaggregated prefill and decode for splitting one large model across multiple GPUs, targets a different problem than GPU under-utilization from many smaller workloads.

**MIG** partitions a physical GPU into fixed hardware slices at the driver level, sized ahead of time (an H200 offers profiles like `1g.18gb`). It sidesteps the whole-device request problem without any scheduler plugin, but repartitioning requires draining every workload on the GPU first, and there's no NCCL between MIG instances on the same physical GPU, so tensor and expert parallelism can't span them. Data parallelism across instances still works through a normal Kubernetes Service.

**vLLM** is the inference engine common to every option above.

## Our Approach

KServe as the control plane, with two serving and scheduling lanes.

For vLLM, `LLMInferenceService`, deployed as plain Kubernetes resources instead of through Knative Serving. Classic `InferenceService`, in either its Serverless or RawDeployment mode, lacks the multi-GPU tensor and pipeline parallelism, multi-node serving, and llm-d EPP routing that large models need. Serverless mode adds a second problem on top: Knative's admission webhook rejects `schedulerName`, so it can't hand pods to KAI Scheduler even where that would otherwise be enough. Scheduled by KAI Scheduler, paired with HAMi-core for memory isolation, on a GPU node pool sized for large models.

For traditional ML, the classic `InferenceService`, on the default Kubernetes scheduler, on a separate GPU node pool sized for smaller models. These models are small enough relative to available GPU sizes that idle capacity is inexpensive, so fractional sharing isn't needed here.

Ray Serve was set aside because its imperative deployment model conflicts with this platform's declarative, GitOps-driven pattern. MIG was set aside because it fixes GPU partitions in hardware ahead of time, so repartitioning means draining every workload on the GPU, unlike KAI Scheduler's per-pod fractional requests. llm-d's disaggregated prefill and decode stays unused for now. The near-term need is packing many small workloads onto a GPU, not splitting one large workload across many. Its EPP router ships regardless as part of `LLMInferenceService`.
