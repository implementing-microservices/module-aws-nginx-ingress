provider "helm" {
  kubernetes {
    load_config_file       = false
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
    host                   = var.kubernetes_cluster_endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws-iam-authenticator"
      args        = ["token", "-i", "${var.kubernetes_cluster_name}"]
    }
  }
}

resource "helm_release" "argocd" {
  name       = "msur"
  chart      = "nginx-stable/nginx-ingress"
  repository = "https://helm.nginx.com/stable"


  set {
    name  = "controller.service.annotations"
    value = <<END
      {
          service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp,
  service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: '60',
  service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: 'true',
  service.beta.kubernetes.io/aws-load-balancer-type: nlb,
  service.beta.kubernetes.io/aws-load-balancer-internal: 'true'
      }
      END
  }

  # Don't install until the EKS cluser nodegroup has started
  # depends_on = [kubernetes_namespace.argo-ns]
}