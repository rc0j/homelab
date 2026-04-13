terraform {
  required_providers {
    adguard = {
      source  = "gmichels/adguard"
      version = ">= 1.6.2"
    }
  }
}

provider "adguard" {
  host     = "192.168.100.5"
  username = "admin"
  password = var.adguard_admin_password # This password is stored in secrets.tfvars and should not be committed to GIT EVER.
  scheme   = "http"
  timeout  = 5 # for now this is Ok, however we might need to adjust in the future. 
  insecure = false # not using https, lets connect insecurely.
}