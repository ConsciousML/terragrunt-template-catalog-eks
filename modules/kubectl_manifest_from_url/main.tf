data "http" "this" {
  url = var.url
}

data "kubectl_file_documents" "this" {
  content = data.http.this.response_body
}

resource "kubectl_manifest" "this" {
  for_each          = data.kubectl_file_documents.this.manifests
  yaml_body         = each.value
  server_side_apply = true
}
