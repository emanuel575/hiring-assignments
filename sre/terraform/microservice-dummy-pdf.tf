resource "kubernetes_deployment_v1" "dummy-pdf-dep" {
  metadata {
    name = "k8s-microservice-dummy-pdf-tf"
    labels = {
      app = "dummy-go-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        "dummy-pdf" = "dummy-go-app"
      }
    }

    template {
      metadata {
        labels = {
          "dummy-pdf" = "dummy-go-app"
        }
      }

      spec {
        container {
          image = "dummy-pdf-or-png"
          name  = "dummygoapp"
          image_pull_policy = "IfNotPresent"
          resources {
            limits = {
              cpu    = "0.5"
              memory = "256Mi"
            }
          }
        }

      }
    }
  }
}

resource "kubernetes_service_v1" "dummy-pdf-svc" {
  metadata {
    name = "dummy-pdf-service"
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.dummy-pdf-dep.metadata.0.labels.app
    }
    type = "NodePort"
    port {
      port        = 9000  // cluster internal port
      target_port = 3000  // port that application uses
      node_port   = 30123 // port exposed outside cluster
    }
  }

}