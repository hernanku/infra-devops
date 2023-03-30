# HTTP Settings
http_directory = "http"

# Virtual Machine Settings
vm_name                     = "base-ubuntu22-templ-2"
vm_template_name = "base-ubuntu22-1a"
// vm_guest_os_type            = "ubuntu64Guest"
// vm_version                  = 13
// vm_firmware                 = "bios"
vm_cdrom_type               = "sata"
vm_cpu_sockets              = 1
vm_cpu_cores                = 1
vm_mem_size                 = 2048
// vm_disk_size                = 30720
thin_provision              = true
disk_eagerly_scrub          = false
// vm_disk_controller_type     = ["pvscsi"]
// vm_network_card             = "vmxnet3"
vm_boot_wait                = "5s"
ssh_username                = "devops"
ssh_password                = ""

# ISO Objects
iso_file                    = "ubuntu-22.04.1-live-server-amd64.iso"
iso_dir                        = "isos"

# Scripts
// shell_scripts               = ["./scripts/setup_ubuntu2204_withDocker.sh"]
