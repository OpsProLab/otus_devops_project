terraform {
  required_version = ">= 0.12.7"
}

provider "google" {
  version = "~> 2.11.0"
  project = var.project
  region  = var.region
  credentials = "${file("~/.config/GCP/k8s-asterisk-bef1e09569a7.json")}"
}

data "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = "nginx-ingress"
  }
}

resource "google_dns_record_set" "a_gitlab" {
  name = "gitlab.${google_dns_managed_zone.prod.dns_name}"
  managed_zone = "${google_dns_managed_zone.prod.name}"
  type = "A"
  ttl  = 300

  rrdatas = ["${data.kubernetes_service.nginx.load_balancer_ingress.0.ip}"]
}


resource "google_dns_record_set" "a_prometheus" {
  name = "prom.${google_dns_managed_zone.prod.dns_name}"
  managed_zone = "${google_dns_managed_zone.prod.name}"
  type = "A"
  ttl  = 300

  rrdatas = ["${data.kubernetes_service.nginx.load_balancer_ingress.0.ip}"]
}

resource "google_dns_record_set" "a_grafana" {
  name = "graf.${google_dns_managed_zone.prod.dns_name}"
  managed_zone = "${google_dns_managed_zone.prod.name}"
  type = "A"
  ttl  = 300

  rrdatas = ["${data.kubernetes_service.nginx.load_balancer_ingress.0.ip}"]
}

resource "google_dns_managed_zone" "prod" {
  name     = var.zone-name
  dns_name = var.dns-name
}
