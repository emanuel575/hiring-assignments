variable "app_name" {
  type    = string
  default = "python-api"
}

resource "kubernetes_deployment_v1" "python-api-dep" {
  metadata {
    name = var.app_name
    labels = {
      app = "${var.app_name}"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "${var.app_name}"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.app_name}"
        }
      }

      spec {
        container {
          image             = "pythonapi:latest"
          name              = "python-api"
          image_pull_policy = "IfNotPresent"
        #   resources {
        #     limits = {
        #       cpu    = "0.5"
        #       memory = "256Mi"
        #     }
        #   }
          env {
            name  = "DUMMY_PNG_URL"
            value = "http://dummy-pdf-svc:9000"
          }
          env{
            name = "PYTHONUNBUFFERED"
            value = "TRUE"
          }
        }

      }
    }
  }
}

resource "kubernetes_service_v1" "python-api-svc" {
  metadata {
    name = "python-api-svc"
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.python-api-dep.metadata.0.labels.app
    }
    type = "NodePort"
    port {
      port        = 9001  // cluster internal port
      target_port = 5000  // port that application uses
      node_port   = 30123 // port exposed outside cluster
    }
  }

}