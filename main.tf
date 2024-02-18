terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.13"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=3.0.0"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  token     = var.yc_token
}
provider "tls" {}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_ssh" {
  filename        = "id_rsa"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0600"
}

resource "local_file" "public_ssh" {
  filename        = "id_rsa.pub"
  content         = tls_private_key.ssh.public_key_openssh
  file_permission = "0600"
}

resource "local_file" "hosts" {
  filename = "ansible/hosts"
  content = templatefile("hosts.tpl",
    {
      db_hosts      = yandex_compute_instance.db.*.hostname
      web-lb_hosts  = yandex_compute_instance.web-lb.*.hostname
      backend_hosts = yandex_compute_instance.backend.*.hostname
      grafana       = yandex_compute_instance.grafana.*.hostname
      # vmetrics      = yandex_compute_instance.vmetrics.*.hostname
  })
  depends_on = [
    yandex_compute_instance.db,
    yandex_compute_instance.backend,
    yandex_compute_instance.web-lb,
    yandex_compute_instance.grafana,
    # yandex_compute_instance.vmetrics
  ]
}

# resource "yandex_iam_service_account" "ig-sa" {
#   name        = "ig-sa"
#   description = "service account to manage IG"
# }

# resource "yandex_resourcemanager_folder_iam_member" "editor" {
#   folder_id = var.folder_id
#   role      = "editor"
#   member    = "serviceAccount:${yandex_iam_service_account.ig-sa.id}"
#   depends_on = [
#     yandex_iam_service_account.ig-sa,
#   ]
# }