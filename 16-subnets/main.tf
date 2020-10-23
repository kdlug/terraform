
resource "google_compute_network" "demo" {
  name = "demo-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "network" {
  name = "demo-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region = "us-central1"
  network = google_compute_network.demo.self_link
}