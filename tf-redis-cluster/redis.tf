
# Create a single Compute Engine instance
resource "google_compute_instance" "redis" {
  name         = "redis"
  machine_type = "f1-micro"
  zone         = "europe-central2-a"
  tags         = ["ssh", "redis"]

  labels = {
    env = "playground"
    project = "redis-cluster"
    owner = "marek"
    managed_by = "terraform"
  }

  metadata = {
    "ssh-keys" = <<EOF
        marek:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKteda/NEcPukzGaT5gvwrUNOX+bTO1HBYRIvlyWVAX8 marek@2021
    EOF
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Install Packages
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq vim-tiny git redis"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

output "redis-ip" {
 value = "${google_compute_instance.redis.network_interface.0.access_config.0.nat_ip}"
}