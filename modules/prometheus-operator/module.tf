
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

resource "kubectl_manifest" "crd_alertmanagerconfigs" {
    yaml_body = file("${path.module}/alertmanagerconfigs.monitoring.coreos.com.crd.yaml")
}

resource "kubectl_manifest" "crd_alertmanagers" {
    yaml_body = file("${path.module}/alertmanagers.monitoring.coreos.com.crd.yaml")
}

resource "kubectl_manifest" "crd_podmonitors" {
    yaml_body = file("${path.module}/podmonitors.monitoring.coreos.com.crd.yaml")
}

resource "kubectl_manifest" "crd_probes" {
    yaml_body = file("${path.module}/probes.monitoring.coreos.com.crd.yaml")
}

resource "kubectl_manifest" "crd_prometheuses" {
    yaml_body = file("${path.module}/prometheuses.monitoring.coreos.com.crd.yaml")
}

resource "kubectl_manifest" "crd_prometheusrules" {
    yaml_body = file("${path.module}/prometheusrules.monitoring.coreos.com.crd.yaml")
}

resource "kubectl_manifest" "crd_servicemonitors" {
    yaml_body = file("${path.module}/servicemonitors.monitoring.coreos.com.crd.yaml")
}

resource "kubectl_manifest" "crd_thanosrulers" {
    yaml_body = file("${path.module}/thanosrulers.monitoring.coreos.com.crd.yaml")
}

resource "kubernetes_cluster_role" "cluster_role" {
  metadata {
    name = "prometheus-operator"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "prometheus-operator"
      "app.kubernetes.io/version" = "0.45.0"
    }
  }

  rule {
    verbs      = ["*"]
    api_groups = ["monitoring.coreos.com"]
    resources  = ["alertmanagers", "alertmanagers/finalizers", "alertmanagerconfigs", "prometheuses", "prometheuses/finalizers", "thanosrulers", "thanosrulers/finalizers", "servicemonitors", "podmonitors", "probes", "prometheusrules"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["apps"]
    resources  = ["statefulsets"]
  }

  rule {
    verbs      = ["*"]
    api_groups = [""]
    resources  = ["configmaps", "secrets"]
  }

  rule {
    verbs      = ["list", "delete"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["get", "create", "update", "delete"]
    api_groups = [""]
    resources  = ["services", "services/finalizers", "endpoints"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = "prometheus-operator"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "prometheus-operator"
      "app.kubernetes.io/version" = "0.45.0"
    }
  }
}

resource "kubernetes_cluster_role_binding" "cluster_role_binding" {
  metadata {
    name = "prometheus-operator"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "prometheus-operator"
      "app.kubernetes.io/version" = "0.45.0"
    }
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

resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = "prometheus-operator"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "prometheus-operator"
      "app.kubernetes.io/version" = "0.45.0"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/name" = "prometheus-operator"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "controller"
          "app.kubernetes.io/name" = "prometheus-operator"
          "app.kubernetes.io/version" = "0.45.0"
        }
      }

      spec {
        container {
          name  = "prometheus-operator"
          image = "quay.io/prometheus-operator/prometheus-operator:v0.45.0"
          args  = ["--kubelet-service=kube-system/kubelet", "--prometheus-config-reloader=quay.io/prometheus-operator/prometheus-config-reloader:v0.45.0"]

          port {
            name           = "http"
            container_port = 8080
          }

          resources {
            limits {
              cpu    = "200m"
              memory = "200Mi"
            }

            requests {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }
        
        service_account_name = kubernetes_service_account.service_account.metadata[0].name
        automount_service_account_token = true

        security_context {
          run_as_user     = 65534
          run_as_non_root = true
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = "prometheus-operator"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "prometheus-operator"
      "app.kubernetes.io/version" = "0.45.0"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }

    selector = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "prometheus-operator"
    }

    cluster_ip = "None"
  }
}

