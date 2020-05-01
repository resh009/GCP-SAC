/*
/---------------------------------------\
| Terraform github actions demo         |
|---------------------------------------|
| Author: Mike Winslow                  |
| E-mail: michael.winslow@broadcom.com  |
\---------------------------------------/
*/

// Variables
//
// GCP
variable "project" {
    default = "demos-sed-isg-integdemo"
}
variable "region" {
    default = "us-west1"
}
variable "zone" {
    default = "us-west1-a"
}
variable "machine_type" {
    default = "f1-micro"
}
variable "image" {
    default = "ubuntu-os-cloud/ubuntu-1804-lts"
}
// Secure Access Cloud
variable "tenant_domain" {
  default = "symcmwinslow.luminatesite.com"
}
//variable "identity_provider" {
  //default = "My-SAC-Okta"
  //default = "local"
//}
variable "luminate_user" {
  default = "michael.winslow@broadcom.com"
  //default = "mikewinslow@symcmwinslow.luminatesite.com"
}
variable "luminate_group" {
  default = "Developers"
  //default = "Developer"
}
variable "git_repo" {
  default = ""
}
variable "git_branch" {
  default = ""
}

// Configure the Google Cloud provider
provider "google" {
 credentials = file("/Users/mw731207/Documents/Keys/gcp/svc_acct-demos-sed-isg-integdemo-298522b5f4bf.json")
 project     = var.project
 region      = var.region
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
    name = "sac-dev-vm-${random_id.instance_id.hex}"
    machine_type = var.machine_type
    zone = var.zone
boot_disk {
    initialize_params {
        image = var.image
    }
}

network_interface {
    network = "default"
    access_config {
    }
}

metadata_startup_script = file("scripts/install-deps.sh")

}

//data "template_file" "user-data" {
  //template = file("tf-tpl/user-data.tpl")
  //vars = {
    //config_script_64   = base64encode(data.template_file.fixtures-config.rendered)
    //config_script_path = "/tmp/node-config.sh"
  //}
//}

//data "template_file" "fixtures-config" {
  //template = file("./tf-tpl/config-node.sh.tpl")
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
  name                 = "AWS-DEV-access-policy"
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

// Output variables

output "nginx-demo-url" {
  value = luminate_web_application.nginx.external_address
}