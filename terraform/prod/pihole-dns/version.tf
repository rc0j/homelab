terraform {
  required_providers {
    pihole = {
      source = "barryw/pihole-v6"
    }
  }
}

# PiHole Config
provider "pihole" {
  url      = "http://192.168.100.5"
  password = var.pihole_password
}
