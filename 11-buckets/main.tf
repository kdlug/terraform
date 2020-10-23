
resource "google_storage_bucket" "bucket" {
    count = var.bucket_count
    name = var.bucket_name # has to be unique
    location = var.location
    storage_class = var.storage_class

    labels = {
        name = var.bucket_name
        location = var.location
    }

    versioning {
        enabled = true
    }
}