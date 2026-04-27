pm_user = "root@pam"
pm_password  = "raif2121"
pm_api_url = "https://192.168.100.20:8006/api2/json"
target-node = "orion"
# === vm information
name = ["VLPROXY"]
vmid = ["19298"]
ipconfig0 = ["ip=192.168.100.98/24,gw=192.168.100.1"]
macaddr = ["BC:24:11:00:4B:62"]
bridge = "vmbr0"
template = "debian-template-restore"
memory = ["512"]
cores = 1
disksize = "4G"
onboot = true
ssh_keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJi9QOy/QVWlFd0+aJ1b4rhrze1C/HPYW0IDAvH5Ic9x raifcoonjah@protonmail.com" ]
