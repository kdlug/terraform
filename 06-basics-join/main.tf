resource "google_compute_instance" "default" {
    count = length(var.name_count)
    name = "list-${count.index+1}"
    machine_type = var.machine_type["dev"]
    zone = "europe-west3-a"

    boot_disk {
        initialize_params {
            image = var.image
        }
    }

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