terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.9.4"
    }
  }
}

variable "namespace" {
  type = string
}

resource "kubernetes_cluster_role" "cluster_role" {
  metadata {
    name = "prometheus"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes", "nodes/metrics", "services", "endpoints", "pods"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs             = ["get"]
    non_resource_urls = ["/metrics"]
  }
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name = "prometheus"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding" "prometheus" {
  metadata {
    name = "prometheus"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.service_account.metadata[0].name
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_role.metadata[0].name
  }
}

resource "kubectl_manifest" "prometheus" {
    yaml_body = templatefile("${path.module}/prometheus.yaml", { namespace = var.namespace, service_account_name = kubernetes_service_account.service_account.metadata[0].name } )
}
