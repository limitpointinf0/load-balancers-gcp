// Configure the Google Cloud provider
provider "google" {
    credentials = file(var.creds_path)
    project     = var.project
    region      = var.region
}

// Add Firewall Rule
resource "google_compute_firewall" "nginx-fw" {
    name    = "test-web-lb"
    network = var.net

    allow {
        protocol = "icmp"
    }

    allow {
        protocol = "tcp"
        ports    = ["80"]
    }
}


resource "random_id" "instance_id" {
    byte_length = 8
}

// Asia Southeast
resource "google_compute_instance" "ase" {
    name         = "ase-vm-${random_id.instance_id.hex}"
    machine_type = var.size
    zone         = var.zone_ase

    boot_disk {
        initialize_params {
            image = var.image
        }
    }

    metadata_startup_script = "${file("docker-nginx.sh")}"

    network_interface {
        network = var.net

        access_config {}
    }
}

// Asia East
resource "google_compute_instance" "ae" {
    name         = "ae-vm-${random_id.instance_id.hex}"
    machine_type = var.size
    zone         = var.zone_ae

    boot_disk {
        initialize_params {
            image = var.image
        }
    }

    metadata = {
        ssh-keys = "chris:${file("~/.ssh/id_rsa.pub")}"
    }

    metadata_startup_script = "${file("docker-nginx.sh")}"

    network_interface {
        network = var.net

        // has an external ip
        access_config {}
    }
}

// Asia Northeast
resource "google_compute_instance" "ane" {
    name         = "ane-vm-${random_id.instance_id.hex}"
    machine_type = var.size
    zone         = var.zone_ane

    boot_disk {
        initialize_params {
            image = var.image
        }
    }

    metadata = {
        ssh-keys = "chris:${file("~/.ssh/id_rsa.pub")}"
    }

    metadata_startup_script = "${file("docker-nginx.sh")}"

    network_interface {
        network = var.net

        // has an external ip
        access_config {}
    }
}

// Test VM
resource "google_compute_instance" "test" {
    name         = "test-vm-${random_id.instance_id.hex}"
    machine_type = var.size
    zone         = var.zone_test

    boot_disk {
        initialize_params {
            image = var.image
        }
    }

    metadata = {
        ssh-keys = "chris:${file("~/.ssh/id_rsa.pub")}"
    }

    metadata_startup_script = "${file("siege.sh")}"

    network_interface {
        network = var.net

        // has an external ip
        access_config {}
    }
}


// Unmanaged Instance Groups
resource "google_compute_instance_group" "igase" {
    name        = "igase"
    description = "Instance group for ASE zone"

    instances = [
        google_compute_instance.ase.id,
    ]

    zone = var.zone_ase

    named_port {
        name = "http"
        port = "80"
    }
}

resource "google_compute_instance_group" "igae" {
    name        = "igae"
    description = "Instance group for AE zone"

    instances = [
        google_compute_instance.ae.id,
    ]

    zone = var.zone_ae

    named_port {
        name = "http"
        port = "80"
    }
}

resource "google_compute_instance_group" "igane" {
    name        = "igane"
    description = "Instance group for ANE zone"

    instances = [
        google_compute_instance.ane.id,
    ]

    zone = var.zone_ane

    named_port {
        name = "http"
        port = "80"
    }
}


// External IP outputs
output "ase-ip" {
    value = google_compute_instance.ase.network_interface.0.access_config.0.nat_ip
}

output "ae-ip" {
    value = google_compute_instance.ae.network_interface.0.access_config.0.nat_ip
}

output "ane-ip" {
    value = google_compute_instance.ane.network_interface.0.access_config.0.nat_ip
}

output "test-ip" {
    value = google_compute_instance.test.network_interface.0.access_config.0.nat_ip
}