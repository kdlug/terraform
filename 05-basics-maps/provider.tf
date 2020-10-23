variable "path" {default = "/home/katarzynadlugolecka/terraform/credentials"}
provider "google" {
    project = "sharp-sandbox-292115"
    region = "europe-west3-a"
    credentials = file("${var.path}/secrets.json")
}