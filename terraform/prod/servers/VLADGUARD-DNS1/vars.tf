variable "name" {
    type = list(string)
}

variable "target-node" {
    type = string
}

variable "template" {
    type = string
    default = "debian-template-restore"
}

variable "onboot" {
    type = bool
    default = false
}

variable "vmid" {
    type = list(number)
}

variable "cores" {
    type = number
    default = 1
}

variable "description" {
    type = string
    default = "This VM is created and is managed by Terraform. Any manual changes to this VM may be overwritten by Terraform during the next apply."
}

variable "ipconfig0" {
    type = list(string)
}

variable "sockets" {
    type = number 
    default = 1
}

variable "memory" {
    type = list(number)
}

variable "disksize" {
    type = string
}

variable "bridge" {
    type = string
}

variable "macaddr" {
    type = list(string)
}

variable "pm_api_url" {
  type = string
}

variable "pm_user" {
  type = string
}

variable "pm_password" {
  type = string
}

variable "ssh_keys" {
    type = list(string) 
  
}

variable "docker_vm" {
    type = bool
    default = false
}  
