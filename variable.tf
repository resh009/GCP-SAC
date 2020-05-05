/*
/---------------------------------------\
| Terraform github actions demo - GCP   |
|---------------------------------------|
| Author: Mike Winslow                  |
| E-mail: michael.winslow@broadcom.com  |
\---------------------------------------/
*/
//Variables

variable "project_name" {
  //type        = "string"
  description = "The name of the project to instanciate the instance at."
  default     = "demos-sed-isg-integdemo"
}

variable "region_name" {
  //type        = "string"
  description = "The region that this terraform configuration will instanciate at."
  default     = "us-west1"
}

variable "zone_name" {
  //type        = "string"
  description = "The zone that this terraform configuration will instanciate at."
  default     = "us-west1-a"
}

variable "machine_size" {
  //type        = "string"
  description = "The size that this instance will be."
  //default     = "f1-micro"
  default     = "e2-medium"
}

variable "image_name" {
  //type        = "string"
  description = "The kind of VM this instance will become"
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
}

//variable "script_path" {
  //type        = "string"
  //description = "Location of the Startup Script"
  //default     = "./scripts/install-deps.sh"
//}

// Secure Access Cloud
variable "tenant_domain" {
  default = "symcmwinslow.luminatesite.com"
}
variable "luminate_user" {
  default = "michael.winslow@broadcom.com"
  //default = "mikewinslow@symcmwinslow.luminatesite.com"
}
variable "luminate_group" {
  default = "Developers"
  //default = "Developer"
}

// GitHub
variable "git_repo" {
  default = ""
}
variable "git_branch" {
  default = ""
}