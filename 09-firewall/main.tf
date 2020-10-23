
resource "google_compute_instance" "default" {
    count = var.machine_count
    name = "list-${count.index+1}"
    machine_type = var.environment == "production" ? var.machine_type : var.machine_type_dev
    zone = var.zone
    can_ip_forward = "false"
    description = "This is our Virtual Machine"

    tags = ["allow-http", "allow-https"] # FIREWALL

    boot_disk {
        initialize_params {
            image = var.image
            size = "20" # GB
        }
    }

    labels = {
        name = "list-${count.index+1}"
        machine_type = var.environment == "production" ? var.machine_type : var.machine_type_dev

    }

    metadata = {
        size = "20"
        foo = "bar"
    }

    metadata_startup_script = "echo hello > test.txt" # "../script.sh"

    network_interface {
        network = "default"
    }

    service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }
}


output "machine_type" { value = "${google_compute_instance.default.*.machine_type}" }
output "name" { value = "${google_compute_instance.default.*.name}" }
output "zone" { value = "${google_compute_instance.default.*.zone}" }

output "instance_id" { value = join(",", google_compute_instance.default.*.id)}