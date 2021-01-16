terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.2"
    }
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "operators"    
  }
}

module "prometheus-operator" {
  source = "./modules/prometheus-operator"
  namespace = "operators"
}
