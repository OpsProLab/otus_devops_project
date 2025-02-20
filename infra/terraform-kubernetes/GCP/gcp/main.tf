terraform {
  required_version = ">= 0.12.7"
}
provider "google" {
  version = "~> 2.11.0"
  project = var.project
  region  = var.region
  credentials = "${file("~/.config/GCP/opsprolab-asterisk-docker-ac2583b8f7b6.json")}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Разворачиваем CLUSTER GCP
# ---------------------------------------------------------------------------------------------------------------------

resource "google_project_service" "cluster" {
  project = var.project
  service = "container.googleapis.com"
}

resource "google_container_cluster" "cluster" {
  name = var.cluster_name
  project  = var.project
  location = var.location
  enable_legacy_abac = "true"
  remove_default_node_pool = true
  depends_on = ["google_project_service.cluster"]


  initial_node_count = 1

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = true
    }
    kubernetes_dashboard {
      disabled = true
    }
    network_policy_config {
      disabled = true
    }
  }
  node_config {
    image_type   = "COS"
    machine_type = "n1-standard-1"


    tags = [ "network-cluster" ]

    disk_size_gb = "50"
    disk_type    = "pd-standard"
    #preemptible  = false

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
} 

# ---------------------------------------------------------------------------------------------------------------------
# Создаем pool основной ноды 
# ---------------------------------------------------------------------------------------------------------------------

resource "google_container_node_pool" "node_pool" {
  name     = var.pool_name
  project  = var.project
  location = var.location
  cluster  = var.cluster_name

  initial_node_count = "1"

   autoscaling {
    min_node_count = "1"
    max_node_count = "2"
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  node_config {
    image_type   = "COS"
    machine_type = "n1-standard-1"


    tags = [ "network-cluster" ]

    disk_size_gb = "50"
    disk_type    = "pd-standard"
    #preemptible  = false

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Создаем pool ноды services (git-lab, monitoring, loging)
# ---------------------------------------------------------------------------------------------------------------------
/* resource "google_container_node_pool" "node_services" {
  name     = "services"
  project  = var.project
  location = var.location
  cluster  = var.cluster_name

  initial_node_count = "1"

  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  node_config {
    image_type   = "COS"
    machine_type = "n1-standard-2"


    tags = [ "network-cluster" ]

    disk_size_gb = "30"
    disk_type    = "pd-standard"
    #preemptible  = false

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
} 

 */