locals {
    // local variables
    name = "${var.name}-${var.machine_type}"
}

resource "google_compute_instance" "default" {
    name = local.name
    machine_type = var.machine_type
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