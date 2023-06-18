locals {
  kubestack_config = {
    region                  = "us-central1"
    base_domain             = "my-n8n-setup.com"
    cluster_node_locations  = "us-central1-b,us-central1-c"
    disable_default_ingress = true
  }
}