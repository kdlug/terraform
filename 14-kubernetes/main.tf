module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "sharp-sandbox-292115" // changed
  name                       = "gke-test-1"
  region                     = "us-central1"
  zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
  network                    = "default" // changed
  subnetwork                 = "default" // changed
  ip_range_pods              = ""  // changed
  ip_range_services          = "" //  changed
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = false // changed

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-medium"
      node_locations     = "us-central1-b,us-central1-c"
      min_count          = 1
      max_count          = 2 // changed (quota errors if the number is too high)
      local_ssd_count    = 0
      disk_size_gb       = 10 //changed (10 is min)
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "886394286171-compute@developer.gserviceaccount.com" // changed IAM & Admin -> Compute Engine default service account (owner)
      preemptible        = false
      initial_node_count = 1 // changed
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}