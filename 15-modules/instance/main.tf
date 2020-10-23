module "instance" {
  source = "../../03-01-firewall-rules"
  // overriding variables
  machine_type = "n1-standard-2"
  zone = "europe-west1-a"
}