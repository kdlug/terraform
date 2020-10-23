variable "storage_class" { default = "REGIONAL" }
variable "location" { default = "europe-west3" }
variable "bucket_count" { default = "1" }
variable "bucket_name" { default = "sharp-test-bucket-gcp" } # name should be unique