
# Create a single Compute Engine instance
resource "google_compute_instance" "faasd" {
  name         = "faasd"
  machine_type = "f1-micro"
  zone         = "europe-central2-a"
  tags         = ["ssh", "app", "web"]

  labels = {
    env = "playground"
    project = "faasd"
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

  # Install Flask
  metadata_startup_script = <<EOF
    sudo apt-get update
    sudo apt-get install wget curl htop runc git -y

    curl -sfL https://raw.githubusercontent.com/openfaas/faasd/master/hack/install.sh | bash -s -
    systemctl status -l containerd --no-pager
    journalctl -u faasd-provider --no-pager
    systemctl status -l faasd-provider --no-pager
    systemctl status -l faasd --no-pager
    curl -sSLf https://cli.openfaas.com | sh
    sleep 60 && journalctl -u faasd --no-pager
    cat /var/lib/faasd/secrets/basic-auth-password | /usr/local/bin/faas-cli login --password-stdin
    
  EOF
  

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

output "faasd-ip" {
 value = "${google_compute_instance.app.network_interface.0.access_config.0.nat_ip}"
}