resource "kubernetes_manifest" "namespace_olm" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "olm"
    }
  }
}

resource "kubernetes_manifest" "namespace_operators" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "operators"
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_olm_operator_serviceaccount" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "name" = "olm-operator-serviceaccount"
      "namespace" = "olm"
    }
  }
}

resource "kubernetes_manifest" "clusterrole_system_controller_operator_lifecycle_manager" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "system:controller:operator-lifecycle-manager"
    }
    "rules" = [
      {
        "apiGroups" = [
          "*",
        ]
        "resources" = [
          "*",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "nonResourceURLs" = [
          "*",
        ]
        "verbs" = [
          "*",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_olm_operator_binding_olm" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "olm-operator-binding-olm"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "system:controller:operator-lifecycle-manager"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "olm-operator-serviceaccount"
        "namespace" = "olm"
      },
    ]
  }
}

resource "kubernetes_manifest" "deployment_olm_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "olm-operator"
      }
      "name" = "olm-operator"
      "namespace" = "olm"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "olm-operator"
        }
      }
      "strategy" = {
        "type" = "RollingUpdate"
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "olm-operator"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--namespace",
                "$(OPERATOR_NAMESPACE)",
                "--writeStatusName",
                "",
              ]
              "command" = [
                "/bin/olm",
              ]
              "env" = [
                {
                  "name" = "OPERATOR_NAMESPACE"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "metadata.namespace"
                    }
                  }
                },
                {
                  "name" = "OPERATOR_NAME"
                  "value" = "olm-operator"
                },
              ]
              "image" = "quay.io/operator-framework/olm@sha256:b9d011c0fbfb65b387904f8fafc47ee1a9479d28d395473341288ee126ed993b"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/healthz"
                  "port" = 8080
                }
              }
              "name" = "olm-operator"
              "ports" = [
                {
                  "containerPort" = 8080
                },
                {
                  "containerPort" = 8081
                  "name" = "metrics"
                  "protocol" = "TCP"
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/healthz"
                  "port" = 8080
                }
              }
              "resources" = {
                "requests" = {
                  "cpu" = "10m"
                  "memory" = "160Mi"
                }
              }
              "terminationMessagePolicy" = "FallbackToLogsOnError"
            },
          ]
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "serviceAccountName" = "olm-operator-serviceaccount"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_catalog_operator" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "catalog-operator"
      }
      "name" = "catalog-operator"
      "namespace" = "olm"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "catalog-operator"
        }
      }
      "strategy" = {
        "type" = "RollingUpdate"
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "catalog-operator"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "-namespace",
                "olm",
                "-configmapServerImage=quay.io/operator-framework/configmap-operator-registry:latest",
                "-util-image",
                "quay.io/operator-framework/olm@sha256:b9d011c0fbfb65b387904f8fafc47ee1a9479d28d395473341288ee126ed993b",
              ]
              "command" = [
                "/bin/catalog",
              ]
              "env" = null
              "image" = "quay.io/operator-framework/olm@sha256:b9d011c0fbfb65b387904f8fafc47ee1a9479d28d395473341288ee126ed993b"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/healthz"
                  "port" = 8080
                }
              }
              "name" = "catalog-operator"
              "ports" = [
                {
                  "containerPort" = 8080
                },
                {
                  "containerPort" = 8081
                  "name" = "metrics"
                  "protocol" = "TCP"
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/healthz"
                  "port" = 8080
                }
              }
              "resources" = {
                "requests" = {
                  "cpu" = "10m"
                  "memory" = "80Mi"
                }
              }
              "terminationMessagePolicy" = "FallbackToLogsOnError"
            },
          ]
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "serviceAccountName" = "olm-operator-serviceaccount"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "clusterrole_aggregate_olm_edit" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
        "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
      }
      "name" = "aggregate-olm-edit"
    }
    "rules" = [
      {
        "apiGroups" = [
          "operators.coreos.com",
        ]
        "resources" = [
          "subscriptions",
        ]
        "verbs" = [
          "create",
          "update",
          "patch",
          "delete",
        ]
      },
      {
        "apiGroups" = [
          "operators.coreos.com",
        ]
        "resources" = [
          "clusterserviceversions",
          "catalogsources",
          "installplans",
          "subscriptions",
        ]
        "verbs" = [
          "delete",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrole_aggregate_olm_view" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
        "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
        "rbac.authorization.k8s.io/aggregate-to-view" = "true"
      }
      "name" = "aggregate-olm-view"
    }
    "rules" = [
      {
        "apiGroups" = [
          "operators.coreos.com",
        ]
        "resources" = [
          "clusterserviceversions",
          "catalogsources",
          "installplans",
          "subscriptions",
          "operatorgroups",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "packages.operators.coreos.com",
        ]
        "resources" = [
          "packagemanifests",
          "packagemanifests/icon",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "operatorgroup_global_operators" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind" = "OperatorGroup"
    "metadata" = {
      "name" = "global-operators"
      "namespace" = "operators"
    }
  }
}

resource "kubernetes_manifest" "operatorgroup_olm_operators" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "operators.coreos.com/v1"
    "kind" = "OperatorGroup"
    "metadata" = {
      "name" = "olm-operators"
      "namespace" = "olm"
    }
    "spec" = {
      "targetNamespaces" = [
        "olm",
      ]
    }
  }
}

resource "kubernetes_manifest" "clusterserviceversion_packageserver" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind" = "ClusterServiceVersion"
    "metadata" = {
      "labels" = {
        "olm.version" = "0.16.1"
      }
      "name" = "packageserver"
      "namespace" = "olm"
    }
    "spec" = {
      "apiservicedefinitions" = {
        "owned" = [
          {
            "containerPort" = 5443
            "deploymentName" = "packageserver"
            "description" = "A PackageManifest is a resource generated from existing CatalogSources and their ConfigMaps"
            "displayName" = "PackageManifest"
            "group" = "packages.operators.coreos.com"
            "kind" = "PackageManifest"
            "name" = "packagemanifests"
            "version" = "v1"
          },
        ]
      }
      "description" = "Represents an Operator package that is available from a given CatalogSource which will resolve to a ClusterServiceVersion."
      "displayName" = "Package Server"
      "install" = {
        "spec" = {
          "clusterPermissions" = [
            {
              "rules" = [
                {
                  "apiGroups" = [
                    "authorization.k8s.io",
                  ]
                  "resources" = [
                    "subjectaccessreviews",
                  ]
                  "verbs" = [
                    "create",
                    "get",
                  ]
                },
                {
                  "apiGroups" = [
                    "",
                  ]
                  "resources" = [
                    "configmaps",
                  ]
                  "verbs" = [
                    "get",
                    "list",
                    "watch",
                  ]
                },
                {
                  "apiGroups" = [
                    "operators.coreos.com",
                  ]
                  "resources" = [
                    "catalogsources",
                  ]
                  "verbs" = [
                    "get",
                    "list",
                    "watch",
                  ]
                },
                {
                  "apiGroups" = [
                    "packages.operators.coreos.com",
                  ]
                  "resources" = [
                    "packagemanifests",
                  ]
                  "verbs" = [
                    "get",
                    "list",
                  ]
                },
              ]
              "serviceAccountName" = "olm-operator-serviceaccount"
            },
          ]
          "deployments" = [
            {
              "name" = "packageserver"
              "spec" = {
                "replicas" = 2
                "selector" = {
                  "matchLabels" = {
                    "app" = "packageserver"
                  }
                }
                "strategy" = {
                  "type" = "RollingUpdate"
                }
                "template" = {
                  "metadata" = {
                    "labels" = {
                      "app" = "packageserver"
                    }
                  }
                  "spec" = {
                    "containers" = [
                      {
                        "command" = [
                          "/bin/package-server",
                          "-v=4",
                          "--secure-port",
                          "5443",
                          "--global-namespace",
                          "olm",
                        ]
                        "image" = "quay.io/operator-framework/olm@sha256:b9d011c0fbfb65b387904f8fafc47ee1a9479d28d395473341288ee126ed993b"
                        "imagePullPolicy" = "Always"
                        "livenessProbe" = {
                          "httpGet" = {
                            "path" = "/healthz"
                            "port" = 5443
                            "scheme" = "HTTPS"
                          }
                        }
                        "name" = "packageserver"
                        "ports" = [
                          {
                            "containerPort" = 5443
                          },
                        ]
                        "readinessProbe" = {
                          "httpGet" = {
                            "path" = "/healthz"
                            "port" = 5443
                            "scheme" = "HTTPS"
                          }
                        }
                        "resources" = {
                          "requests" = {
                            "cpu" = "10m"
                            "memory" = "50Mi"
                          }
                        }
                        "securityContext" = {
                          "runAsUser" = 1000
                        }
                        "terminationMessagePolicy" = "FallbackToLogsOnError"
                        "volumeMounts" = [
                          {
                            "mountPath" = "/tmp"
                            "name" = "tmpfs"
                          },
                        ]
                      },
                    ]
                    "nodeSelector" = {
                      "kubernetes.io/os" = "linux"
                    }
                    "serviceAccountName" = "olm-operator-serviceaccount"
                    "volumes" = [
                      {
                        "emptyDir" = {}
                        "name" = "tmpfs"
                      },
                    ]
                  }
                }
              }
            },
          ]
        }
        "strategy" = "deployment"
      }
      "installModes" = [
        {
          "supported" = true
          "type" = "OwnNamespace"
        },
        {
          "supported" = true
          "type" = "SingleNamespace"
        },
        {
          "supported" = true
          "type" = "MultiNamespace"
        },
        {
          "supported" = true
          "type" = "AllNamespaces"
        },
      ]
      "keywords" = [
        "packagemanifests",
        "olm",
        "packages",
      ]
      "links" = [
        {
          "name" = "Package Server"
          "url" = "https://github.com/operator-framework/operator-lifecycle-manager/tree/master/pkg/package-server"
        },
      ]
      "maintainers" = [
        {
          "email" = "openshift-operators@redhat.com"
          "name" = "Red Hat"
        },
      ]
      "maturity" = "alpha"
      "minKubeVersion" = "1.11.0"
      "provider" = {
        "name" = "Red Hat"
      }
      "version" = "0.16.1"
    }
  }
}

resource "kubernetes_manifest" "catalogsource_operatorhubio_catalog" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" = "operators.coreos.com/v1alpha1"
    "kind" = "CatalogSource"
    "metadata" = {
      "name" = "operatorhubio-catalog"
      "namespace" = "olm"
    }
    "spec" = {
      "displayName" = "Community Operators"
      "image" = "quay.io/operatorhubio/catalog:latest"
      "publisher" = "OperatorHub.io"
      "sourceType" = "grpc"
    }
  }
}
