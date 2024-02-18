resource "yandex_vpc_network" "net01" {
  name = "net01"
}

resource "yandex_vpc_subnet" "subnet01" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net01.id
  v4_cidr_blocks = ["192.168.100.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet02" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.net01.id
  v4_cidr_blocks = ["192.168.101.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet03" {
  name           = "subnet3"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.net01.id
  v4_cidr_blocks = ["192.168.102.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "gateway01"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "route-table"
  network_id = yandex_vpc_network.net01.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}