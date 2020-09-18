terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.2"
    }
    kubernetes-alpha = {
      source  = "hashicorp/kubernetes-alpha"
      version = "~> 0.2.1"
    }
  }
}

provider "kubernetes-alpha" {
  server_side_planning = true
  config_path = "~/.kube/config"
}

module "operator-lifecycle-manager" {
  source        = "./modules/operator-lifecycle-manager"
}
