# Terraform

## Setup

### Installing Terraform

```bash
TERRAFORM_VERSION=0.12.29 && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && sudo unzip -oq terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
```

### Visual Studio plugins

- Terraform (Syntax highliting)
- Bash

Ctrl + Shift + P - Terraform: Enable Language Server

### GC Regions and zones

https://cloud.google.com/compute/docs/regions-zones

### GC Machine types

https://cloud.google.com/compute/docs/machine-types


### Installing GC SDK

https://cloud.google.com/sdk/docs/install

gcloud init

### Credentials

Create service account key:
https://console.cloud.google.com/apis/credentials/serviceaccountkey

Generate a service account:
- Service account: Compute Engine default service account
- JSON

Put credentials in `$HOME/terraform/credentials/secrets.json` file.

Create an init instance `cd 01-init`

```
terraform init
terraform plan
terraform apply
terraform apply -autoapprove
```

To destroy a machine

```
terraform destroy
```

## Basics

### Variables

#### Defining variables

Variables can be defined in a new file f.ex. called variables.tf placed in the project folder.

```
variable "image" { default = "ubuntu-os-cloud/ubuntu-1604-lts" }
```

#### Interpolating variables

```
// old way
image = "${var.image}"
// new way (terraform 12)
image = var.image

```

#### Locals

```
locals {
    // local variables
    name = "${var.name}-${var.machine_type}"
}

resource "google_compute_instance" "default" {
    name = local.name
    ...
}
```

### Outputs

Printing information to the screen.

```
resource "google_compute_instance" "default" {
    name = var.name
    machine_type = var.machine_type
    zone = "europe-west3-a"
    ...
}

output "machine_type" { value = "${google_compute_instance.default.machine_type}" }
```

### Lists, count, lenght

#### Defining a list variable

```
variable "name_count" { default = ["server1","server2","server3"] }
```

#### Interpolation

```
resource "google_compute_instance" "default" {
    count = length(var.name_count) 
    name = "list-${count.index+1}" // 3 instances will be created
...
}
```

#### Printing outputs

Use *

```
output "machine_type" { value = "${google_compute_instance.default.*.machine_type}" }
output "name" { value = "${google_compute_instance.default.*.name}" }
output "zone" { value = "${google_compute_instance.default.*.zone}" }
```

### Maps

#### Definig a map

```
variable "machine_type" { 
    type = "map"
    default = {
        dev = "n1-standard-1" 
        prod = "production_box_wont_work"
    }
}
```

#### Interpolation

```
 machine_type = var.machine_type["dev"]
```

### Join

```
output "instance_id" { value = join(",", google_compute_instance.default.*.id)}
```

### Dependency

```
resource "google_compute_instance" "default" {
    ...
    depends_on = [google_compute_instance.second"]
}
    
...

resource "google_compute_instance" "second"  {
    ...
}
```
### Conditionals

CONDITION ? TRUE : FALSE

```
resource "google_compute_instance" "default" {
    ...
    machine_type = var.environment == "production" ? var.machine_type : var.machine_type_dev
    ...
}
```

## Firewall rules

```
resource "google_compute_firewall" "allow_http" {
    name = "allow-http"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    target_tags = ["allow-http"]
}

resource "google_compute_firewall" "allow_https" {
    name = "allow-https"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["443"]
    }

    target_tags = ["allow-https"]
}
```

Tags

```
resource "google_compute_instance" "default" {
    ...
    tags = ["allow-http", "allow-https"] # FIREWALL
    ...
}
```

## Volumes 

```
// instance
resource "google_compute_instance" "default" {
    ...
}

//volume
resource "google_compute_disk" "default" {
    name = "test-desk"
    type = "pd-ssd"
    zone = var.zone
    size = "10" // GB
}

// attach the disk to the instance
resource "google_compute_attached_disk" "default" {
    disk = google_compute_disk.default.self_link
    instance = google_compute_instance[0].default.self_link
}
```

## Database

```
# Create database

resource "google_sql_database_instance" "gcp_database" {
    name = var.name
    region = urope-west2 # region, not zone
    database_version = var.database_version

    settings {
        tier = var.tier
        disk_size = var.disk_size
        replication_type = var.replication_type
        activation_policy = var.activation_policy
    }
}

# Create user

resource "google_sql_user" "admin" {
    count = 1
    name = var.user_name
    host = var.user_host
    password = var.user_password
    instance = google_sql_database_instance.gcp_database.name
}
```

After apply you can get the following error:

```
Error: Error, failed to create instance gcpdatabase: googleapi: Error 403: Cloud SQL Admin API has not been used in project XXXXX before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/sqladmin.googleapis.com/overview?project=XXXXX then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry., accessNotConfigured

```
You have to click above link and activate `Cloud SQL Admin API`

## Bucket

```
resource "google_storage_bucket" "bucket" {
    count = var.bucket_count
    name = var.bucket_name # has to be unique (it's global)
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
```

## Kubernetes

Google modules http://registry.terraform.io/providers/hashicorp/google/latest


Kubernetes engine:
http://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest


Go to google cloud console 
-> Enable Cloud Resource Manager API
-> IAM & Admin and make sure that `Compute Engine default service account` has a role Project-> Owner.


```
Error: Module not installed

  on main.tf line 1:
   1: module "gke" {

```
Run `terraform init`

Go to Kubernetes Engine -> connect and run the command-line to get an access

gcloud container clusters get-credentials gke-test-1 --region us-central1 --project sharp-sandbox-292115

## Modules

Docs: https://www.terraform.io/docs/modules/sources.html

```
module "instance" {
  source = "../../03-01-firewall-rules"
  // overriding variables
  machine_type = "n1-standard-2"
  zone = "europe-west1-a"
}
```

# Subnets

Go to VPC network -> VPC network to see all subnets.

```
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
```