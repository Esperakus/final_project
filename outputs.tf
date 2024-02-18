output "external_ip_address_lb" {
  value = yandex_lb_network_load_balancer.web-balancer.listener.*
}

output "external_ip_address_ansible" {
  value = yandex_compute_instance.ansible.*.network_interface.0.nat_ip_address
}