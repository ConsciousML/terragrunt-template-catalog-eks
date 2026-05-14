locals {
  vpc_cidrs = {
    prod           = "10.0.0.0/16"
    staging        = "10.1.0.0/16"
    dev            = "10.2.0.0/16"
    example        = "10.3.0.0/16"
    catalog-eks-ci = "10.4.0.0/16"
  }
}
