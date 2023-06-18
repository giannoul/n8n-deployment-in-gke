terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.0"
    }
  }
}

provider "google" {
  project = "creating-and-150-59627b16"
  region  = "us-central1"
}

provider "kustomization" {
  kubeconfig_raw = module.gke_n8n_cluster.kubeconfig
}

#provider "kubernetes" {
#  config_path    = "~/.kube/config"
#  config_context = "my-context"
#}