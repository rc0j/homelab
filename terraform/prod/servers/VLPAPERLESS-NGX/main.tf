resource "proxmox_vm_qemu" "cloudinit" {
    count = 1
    name = var.name[count.index]
    target_node = var.target-node
    description = var.description
    clone = var.template
    cores = var.cores
    sockets = var.sockets
    memory = var.memory[count.index]
    vmid = var.vmid[count.index]
    onboot = var.onboot
    scsihw   = "virtio-scsi-pci"
    
    ssh_user = "root"
    sshkeys = var.ssh_keys[count.index]

    os_type = "cloud-init"
    ipconfig0 = var.ipconfig0[count.index]

    boot = "order=scsi0"
    bootdisk = "scsi0"

    disk {
      type    = "disk"
      slot    = "scsi0"
      storage = "local"
      format = "qcow2"
      size    = var.disksize
    }
  
    disk {
      type    = "cloudinit"
      slot    = "ide2"
      storage = "local"
      format = "qcow2"
    }

    network {
        id = 0
        model = "virtio"
        macaddr = var.macaddr[count.index]
        bridge = var.bridge

    }
}