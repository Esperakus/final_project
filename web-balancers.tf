resource "yandex_compute_instance" "web-lb" {
  platform_id = "standard-v2"
  count       = 2
  name        = "balancer0${count.index + 1}"
  hostname    = "balancer0${count.index + 1}"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    # nat       = true
  }

  metadata = {
    ssh-keys = "almalinux:${tls_private_key.ssh.public_key_openssh}"
  }

}
