resource "kubernetes_manifest" "clusterrole_istio_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "creationTimestamp" = null
      "name" = "istio-operator"
    }
    "rules" = [
      {
        "apiGroups" = [
          "authentication.istio.io",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "config.istio.io",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "install.istio.io",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "networking.istio.io",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "security.istio.io",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "admissionregistration.k8s.io",
        ]
        "resources" = [
          "mutatingwebhookconfigurations",
          "validatingwebhookconfigurations",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "apiextensions.k8s.io",
        ]
        "resources" = [
          "customresourcedefinitions.apiextensions.k8s.io",
          "customresourcedefinitions",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "apps",
          "extensions",
        ]
        "resources" = [
          "daemonsets",
          "deployments",
          "deployments/finalizers",
          "ingresses",
          "replicasets",
          "statefulsets",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "autoscaling",
        ]
        "resources" = [
          "horizontalpodautoscalers",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "monitoring.coreos.com",
        ]
        "resources" = [
          "servicemonitors",
        ]
        "verbs" = [
          "get",
          "create",
          "update",
        ]
      },
      {
        "apiGroups" = [
          "policy",
        ]
        "resources" = [
          "poddisruptionbudgets",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "rbac.authorization.k8s.io",
        ]
        "resources" = [
          "clusterrolebindings",
          "clusterroles",
          "roles",
          "rolebindings",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
          "endpoints",
          "events",
          "namespaces",
          "pods",
          "persistentvolumeclaims",
          "secrets",
          "services",
          "serviceaccounts",
        ]
        "verbs" = [
          "*",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_istio_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "istio-operator"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "istio-operator"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "istio-operator"
        "namespace" = "istio-operator"
      },
    ]
  }
}

resource "kubernetes_manifest" "deployment_istio_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "istio-operator"
      "namespace" = "istio-operator"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "istio-operator"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "istio-operator"
          }
        }
        "spec" = {
          "containers" = [
            {
              "command" = [
                "operator",
                "server",
              ]
              "env" = [
                {
                  "name" = "WATCH_NAMESPACE"
                  "value" = null
                },
                {
                  "name" = "LEADER_ELECTION_NAMESPACE"
                  "value" = "istio-operator"
                },
                {
                  "name" = "POD_NAME"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "metadata.name"
                    }
                  }
                },
                {
                  "name" = "OPERATOR_NAME"
                  "value" = "istio-operator"
                },
                {
                  "name" = "WAIT_FOR_RESOURCES_TIMEOUT"
                  "value" = "300s"
                },
                {
                  "name" = "REVISION"
                  "value" = ""
                },
              ]
              "image" = "docker.io/istio/operator:1.7.1"
              "imagePullPolicy" = "IfNotPresent"
              "name" = "istio-operator"
              "resources" = {
                "limits" = {
                  "cpu" = "200m"
                  "memory" = "256Mi"
                }
                "requests" = {
                  "cpu" = "50m"
                  "memory" = "128Mi"
                }
              }
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "capabilities" = {
                  "drop" = [
                    "ALL",
                  ]
                }
                "privileged" = false
                "readOnlyRootFilesystem" = true
                "runAsGroup" = 1337
                "runAsNonRoot" = true
                "runAsUser" = 1337
              }
            },
          ]
          "serviceAccountName" = "istio-operator"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "namespace_istio_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "labels" = {
        "istio-injection" = "disabled"
        "istio-operator-managed" = "Reconcile"
      }
      "name" = "istio-operator"
    }
  }
}

resource "kubernetes_manifest" "service_istio_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "name" = "istio-operator"
      }
      "name" = "istio-operator"
      "namespace" = "istio-operator"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "http-metrics"
          "port" = 8383
          "targetPort" = 8383
        },
      ]
      "selector" = {
        "name" = "istio-operator"
      }
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_istio_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "name" = "istio-operator"
      "namespace" = "istio-operator"
    }
  }
}

resource "kubernetes_manifest" "customresourcedefinition_istiooperators_install_istio_io" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "labels" = {
        "release" = "istio"
      }
      "name" = "istiooperators.install.istio.io"
    }
    "spec" = {
      "group" = "install.istio.io"
      "names" = {
        "kind" = "IstioOperator"
        "plural" = "istiooperators"
        "shortNames" = [
          "iop",
        ]
        "singular" = "istiooperator"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "description" = "Istio control plane revision"
              "jsonPath" = ".spec.revision"
              "name" = "Revision"
              "type" = "string"
            },
            {
              "description" = "IOP current state"
              "jsonPath" = ".status.status"
              "name" = "Status"
              "type" = "string"
            },
            {
              "description" = "CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is represented in RFC3339 form and is in UTC. Populated by the system. Read-only. Null for lists. More info: https://git.k8s.io/community/contributors/devel/api-conventions.md#metadata"
              "jsonPath" = ".metadata.creationTimestamp"
              "name" = "Age"
              "type" = "date"
            },
          ]
          "name" = "v1alpha1"
          "schema" = {
            "openAPIV3Schema" = {
              "properties" = {
                "apiVersion" = {
                  "description" = "APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#resources"
                  "type" = "string"
                }
                "kind" = {
                  "description" = "Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#types-kinds"
                  "type" = "string"
                }
                "spec" = {
                  "description" = "Specification of the desired state of the istio control plane resource. More info: https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#spec-and-status"
                  "type" = "object"
                  "x-kubernetes-preserve-unknown-fields" = true
                }
                "status" = {
                  "description" = "Status describes each of istio control plane component status at the current time. 0 means NONE, 1 means UPDATING, 2 means HEALTHY, 3 means ERROR, 4 means RECONCILING. More info: https://github.com/istio/api/blob/master/operator/v1alpha1/istio.operator.v1alpha1.pb.html & https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#spec-and-status"
                  "type" = "object"
                  "x-kubernetes-preserve-unknown-fields" = true
                }
              }
              "type" = "object"
            }
          }
          "served" = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}
