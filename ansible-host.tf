resource "yandex_compute_instance" "ansible" {
  platform_id = "standard-v2"
  name        = "ansible"
  hostname    = "ansible"

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
    nat       = true
  }

  metadata = {
    ssh-keys = "almalinux:${tls_private_key.ssh.public_key_openssh}"
  }

  connection {
    type        = "ssh"
    user        = "almalinux"
    private_key = tls_private_key.ssh.private_key_pem
    host        = self.network_interface.0.nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'host is up'",
      "sudo dnf install -y epel-release",
      "sudo dnf install -y ansible"
    ]
  }

  provisioner "file" {
    source      = "ansible"
    destination = "/home/almalinux"
  }

  provisioner "file" {
    source      = "id_rsa"
    destination = "/home/almalinux/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "id_rsa.pub"
    destination = "/home/almalinux/.ssh/id_rsa.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/almalinux/.ssh/id_rsa"
    ]
  }

  provisioner "file" {
    source      = "./ansible.cfg"
    destination = "/home/almalinux/ansible.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "ansible-playbook -u almalinux -i /home/almalinux/ansible/hosts /home/almalinux/ansible/playbooks/main.yml",
    ]
  }

  depends_on = [
    yandex_compute_instance.backend,
    yandex_compute_instance.db,
    yandex_compute_instance.web-lb,
    yandex_compute_instance.grafana,
    # yandex_compute_instance.vmetrics
  ]
}