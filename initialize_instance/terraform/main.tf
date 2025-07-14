provider "google" {
  project = "esoteric-kiln-463912-m2"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

resource "google_compute_instance" "gpu_vm" {
  name         = "benchmark-gromacs-gpu-docker-nvidia-tesla-t4"
  machine_type = "n1-standard-1"
  zone         = "europe-west1-b"

  tags = ["http-server", "https-server"]

  metadata = {
    enable-osconfig = "TRUE"
    docker_user     = "candide_champion_bind_research_c"
  }

  metadata_startup_script = file("../startup.sh")

  service_account {
    email  = "891723074586-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2404-noble-amd64-v20250701"
      size  = 200
      type  = "pd-balanced"
    }
    auto_delete = true
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
    }
    stack_type = "IPV4_ONLY"
  }

  guest_accelerator {
    type  = "nvidia-tesla-t4"
    count = 1
  }

  scheduling {
    on_host_maintenance = "TERMINATE"
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  labels = {
    goog-ops-agent-policy = "v2-x86-template-1-4-0"
    goog-ec-src           = "vm_add-gcloud"
  }

  reservation_affinity {
    type = "ANY_RESERVATION"
  }
}
