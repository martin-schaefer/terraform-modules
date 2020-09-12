terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.2"
    }
    kubernetes-alpha = {
      source  = "hashicorp/kubernetes-alpha"
      version = "~> 0.2.0"
    }
  }
}

module "operator-lifecycle-manager" {
  source        = "./modules/operator-lifecycle-manager"
}

module "istio-operator" {
  source  = "./modules/istio-operator"
}
