provider "google" {
  region  = var.gcp_region
  project = var.gcp_project_name
}

resource "google_compute_network" "two-tier-tfe-demo-app" {
  name = "two-tier-tfe-demo-app-vpc"
}

resource "google_compute_target_pool" "two-tier-tfe-demo-app" {
  name      = "two-tier-tfe-demo-app-target-pool"
  instances = google_compute_instance.two-tier-tfe-demo-app.*.self_link
}

resource "google_compute_forwarding_rule" "two-tier-tfe-demo-app" {
  name       = "two-tier-tfe-demo-app-forwarding-rule"
  target     = "${google_compute_target_pool.two-tier-tfe-demo-app.self_link}"
  port_range = "80"
}


resource "google_compute_firewall" "two-tier-tfe-demo-app" {
  name    = "two-tier-tfe-demo-app-firewall"
  network = google_compute_network.two-tier-tfe-demo-app.self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["two-tier-tfe-demo-app"]
}

resource "google_compute_instance" "two-tier-tfe-demo-app" {
  count = var.num_instances

  name         = "${var.gcp_instance_name}-${count.index}"
  machine_type = var.gcp_instance_machine_type
  zone         = var.gcp_region_zone
  tags         = ["two-tier-tfe-demo-app", "neil-test"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = google_compute_network.two-tier-tfe-demo-app.self_link

    access_config {
      # Ephemeral
    }
  }
}

