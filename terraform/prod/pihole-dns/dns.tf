locals {
  dns_records = {
    "bitwarden"     = "192.168.100.99"
    "centreon-prod" = "192.168.100.7"
    "dns"           = "192.168.100.5"
    "dns2"          = "192.168.100.6"
    "docker-node01" = "192.168.100.8"
    "jellyfin"      = "192.168.100.100"
    "orion"         = "192.168.100.20"
    "orion-node02"  = "192.168.100.22"
    "pi"            = "192.168.100.21"
  }
}

resource "pihole_dns_record" "records" {
  for_each = local.dns_records
  domain   = each.key
  ip       = each.value
}