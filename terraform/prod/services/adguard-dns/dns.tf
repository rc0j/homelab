locals {
  dns_records = {
    "*.awesomesandwish.xyz" = "192.168.100.8"
    "bitwarden"     = "192.168.100.99"
    "centreon-prod" = "192.168.100.7"
    "dns"           = "192.168.100.5"
    "dns2"          = "192.168.100.6"
    "docker-node01" = "192.168.100.8"
    "jellyfin"       = "192.168.100.100"
    "orion"         = "192.168.100.20"
    "orion-node02"  = "192.168.100.22"
    "pi"            = "192.168.100.21"
    "git"           = "192.168.100.11"
  }
}

resource "adguard_rewrite" "domain" {
  for_each = local.dns_records
  domain   = each.key
  answer   = each.value
}