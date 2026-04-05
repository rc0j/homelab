terraform {
  required_providers {
    pihole = {
      source = "barryw/pihole-v6"
    }
  }
}

# Configure the PiHole provider
provider "pihole" {
  url      = "http://192.168.100.5"
  password = var.pihole_password
}
