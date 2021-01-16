terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.2"
    }
  }
}

resource "kubernetes_namespace" "namespace_operators" {
  metadata {
    name = "operators"    
  }
}

module "prometheus-operator" {
  source = "./modules/prometheus-operator"
  namespace = kubernetes_namespace.namespace_operators.metadata[0].name
}

resource "kubernetes_namespace" "namespace_prometheus" {
  metadata {
    name = "prometheus"    
  }
}

module "prometheus" {
  source = "./modules/prometheus"
  namespace = kubernetes_namespace.namespace_prometheus.metadata[0].name
}
