data "google_project" "project" {
}

module "gke_n8n_cluster" {
  providers = {
    kubernetes = kubernetes
  }

  source = "github.com/kbst/terraform-kubestack//google/cluster?ref=v0.18.1-beta.0"

  configuration = {
    apps = {
      name_prefix                                 = "n8n"
      base_domain                                 = local.kubestack_config.base_domain
      disable_default_ingress                     = local.kubestack_config.disable_default_ingress
      project_id                                  = data.google_project.project.project_id
      region                                      = local.kubestack_config.region
      cluster_node_locations                      = local.kubestack_config.cluster_node_locations
      cluster_machine_type                        = "e2-standard-2"
      cluster_initial_node_count                  = 1
      cluster_min_node_count                      = 1
      cluster_max_node_count                      = 3
      cluster_disk_size_gb                        = 20
      cluster_disk_type                           = "pd-ssd"
      cluster_preemptible                         = false
      cluster_auto_repair                         = true
      cluster_auto_upgrade                        = true
      cluster_min_master_version                  = "1.25"
      cluster_daily_maintenance_window_start_time = "03:00"
      cluster_extra_oauth_scopes                  = "https://www.googleapis.com/auth/source.read_only,https://www.googleapis.com/auth/compute.readonly"
      disable_workload_identity                   = false
      node_workload_metadata_config               = "GKE_METADATA"
      logging_config_enable_components            = "SYSTEM_COMPONENTS,WORKLOADS"
      monitoring_config_enable_components         = "SYSTEM_COMPONENTS"
    }

    ops = {}
  }
}

data "kustomization_build" "n8n" {
  path = "./manifests"
}

resource "kustomization_resource" "p0" {
  for_each = data.kustomization_build.n8n.ids_prio[0]
  manifest = data.kustomization_build.n8n.manifests[each.value]
  depends_on = [
    module.gke_n8n_cluster
  ]
}

resource "kustomization_resource" "p1" {
  for_each = data.kustomization_build.n8n.ids_prio[1]
  manifest = data.kustomization_build.n8n.manifests[each.value]

  timeouts {
    create = "2m"
  }

  depends_on = [kustomization_resource.p0]
}

resource "kustomization_resource" "p2" {
  for_each = data.kustomization_build.n8n.ids_prio[2]
  manifest = data.kustomization_build.n8n.manifests[each.value]
  timeouts {
    create = "2m"
  }
  depends_on = [kustomization_resource.p1]
}


resource "local_file" "kubeconfig" {
  content  = module.gke_n8n_cluster.kubeconfig
  filename = "/infra/.user/.kube/config"
}

