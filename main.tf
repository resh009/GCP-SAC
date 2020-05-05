/*
/---------------------------------------\
| Terraform github actions demo         |
|---------------------------------------|
| Author: Mike Winslow                  |
| E-mail: michael.winslow@broadcom.com  |
\---------------------------------------/
*/
//Main Action

# This is the provider used to spin up the gcloud instance
provider "google" {
  project = var.project_name
  region  = var.region_name
  zone    = var.zone_name
}

# Locks the version of Terraform for this particular use case
terraform {
  required_version = "~>0.12.0"
    backend "gcs" {
    bucket  = "mwinslow-tf-state-prod"
    prefix  = "terraform/state"
  }
}

# Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

# This creates the google instance
resource "google_compute_instance" "default" {
    name = "sac-dev-vm-${random_id.instance_id.hex}"
    machine_type = var.machine_size
    zone = var.zone_name
boot_disk {
    initialize_params {
        image = var.image_name
    }
  }

network_interface {
    network = "default"
    access_config {
    }
  }
    metadata_startup_script = <<SCRIPT
${file("${path.module}/scripts/install-deps.sh")}
    git_repo = $TF_VAR_git_repo
    git_branch = $TF_VAR_git_branch
    connecto_command = luminate_connector.connector.command
SCRIPT
    }

### Startup Script
//metadata_startup_script = file("scripts/install-deps.sh")
  //vars = {
    //connector_command = luminate_connector.connector.command
    //git_repo = var.git_repo
    //git_branch = var.git_branch
  //}

//data "template_file" "fixtures-config" {
  //template = file("tf-tpl/config-node.sh.tpl")
  //template = file("scripts/install-deps.sh")
  //vars = {
    //connector_command = luminate_connector.connector.command
    //git_repo = var.git_repo
    //git_branch = var.git_branch
  //}
//}

# We create a public IP address for our google compute instance to utilize
//resource "google_compute_address" "static" {
//  name = "vm-public-address"
//}

// Secure Access Cloud (luminate) provider

provider "luminate" {
  api_endpoint = "api.${var.tenant_domain}"
}

resource "luminate_site" "site" {
  name = "GCP-CICD-Site"
}

resource "luminate_connector" "connector" {
  name    = "gcp-cicd-site-connector"
  site_id = luminate_site.site.id
  type    = "linux"
}

resource "luminate_web_application" "nginx" {
  name             = "GCP-SAC-CICD"
  site_id          = luminate_site.site.id
  internal_address = "http://127.0.0.1:8080"
}

resource "luminate_web_access_policy" "web-access-policy" {
  name                 = "GCP-DEV-access-policy"
  identity_provider_id = data.luminate_identity_provider.idp.identity_provider_id
  user_ids             = data.luminate_user.users.user_ids
  group_ids            = data.luminate_group.groups.group_ids
  applications         = [luminate_web_application.nginx.id]
}

// Change for Account in SAC
data "luminate_identity_provider" "idp" {
  identity_provider_name = "My-SAC-Okta"
  //identity_provider_name = "local"
}

data "luminate_user" "users" {
  identity_provider_id = data.luminate_identity_provider.idp.identity_provider_id
  users                = [var.luminate_user]
}

data "luminate_group" "groups" {
  identity_provider_id = data.luminate_identity_provider.idp.identity_provider_id
  groups               = [var.luminate_group]
}