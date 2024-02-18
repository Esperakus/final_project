resource "yandex_lb_target_group" "haproxy-group" {
  name = "haproxy-group"

  target {
    subnet_id = yandex_vpc_subnet.subnet01.id
    address   = yandex_compute_instance.web-lb.0.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet01.id
    address   = yandex_compute_instance.web-lb.1.network_interface.0.ip_address
  }

  depends_on = [
    yandex_compute_instance.web-lb
  ]
}

resource "yandex_lb_network_load_balancer" "web-balancer" {
  name = "web-balancer"
  type = "external"
  listener {
    name = "web-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_lb_target_group.haproxy-group.id
    healthcheck {
      name = "web-health"
      http_options {
        port = 80
      }
      interval = 2
    }
  }
  depends_on = [
    yandex_lb_network_load_balancer.db-balancer
  ]
}

resource "yandex_lb_network_load_balancer" "db-balancer" {
  name = "db-balancer"
  type = "internal"

  listener {
    name        = "db-listener"
    port        = 5432
    target_port = 5432
    internal_address_spec {
      subnet_id  = yandex_vpc_subnet.subnet01.id
      ip_version = "ipv4"
      address    = "192.168.100.200"
    }
  }
  attached_target_group {
    target_group_id = yandex_lb_target_group.haproxy-group.id
    healthcheck {
      name = "db-health"
      tcp_options {
        port = 5432
      }
      interval = 2
    }
  }
}

# resource "yandex_dns_zone" "project" {
#   name             = "project"
#   public           = false
#   private_networks = [yandex_vpc_network.net01.id]
#   zone             = "project."
# }

# resource "yandex_dns_recordset" "db-lb" {
#   # zone_id = "dns42e2dv5t8vjiqha7o"
#   zone_id = yandex_dns_zone.project.id
#   name    = "db.ru-central1.project."
#   type    = "A"
#   ttl     = 200
#   data    = ["192.168.100.200"]
# }