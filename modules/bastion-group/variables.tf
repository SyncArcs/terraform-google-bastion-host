variable "name" {
  type        = string
  default     = "test"
  description = "Name of the resource. Provided by the client when the resource is created. "
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] ."
}

variable "managedby" {
  type        = string
  default     = ""
  description = "ManagedBy, eg 'SyncArcs'."
}

variable "repository" {
  type        = string
  default     = "https://github.com/SyncArcs/terraform-google-bastion-host"
  description = "Terraform current module repo"
}

variable "target_size" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "image_family" {
  description = "Source image family for the Bastion."
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "image_project" {
  description = "Project where the source image for the Bastion comes from"
  type        = string
  default     = "ubuntu-os-cloud"
}

variable "labels" {
  description = "Key-value map of labels to assign to the bastion host"
  type        = map(any)
  default     = {}
}

variable "members" {
  description = "List of IAM resources to allow access to the bastion host"
  type        = list(string)
  default     = []
}

variable "network" {
  description = "Self link for the network on which the Bastion should live"
  type        = string
}

variable "health_check" {
  description = "Health check to determine whether instances are responsive and able to do work"
  type = object({
    type                = string
    initial_delay_sec   = number
    check_interval_sec  = number
    healthy_threshold   = number
    timeout_sec         = number
    unhealthy_threshold = number
    response            = string
    proxy_header        = string
    port                = number
    request             = string
    request_path        = string
    host                = string
    enable_logging      = string
  })
  default = {
    type                = "http"
    initial_delay_sec   = 30
    check_interval_sec  = 30
    healthy_threshold   = 1
    timeout_sec         = 10
    unhealthy_threshold = 5
    response            = ""
    proxy_header        = "NONE"
    port                = 22
    request             = ""
    request_path        = "/"
    host                = ""
    enable_logging      = false
  }
}

variable "service_account_roles" {
  description = "List of IAM roles to assign to the service account."
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/compute.osLogin",
  ]
}

variable "service_account_roles_supplemental" {
  description = "An additional list of roles to assign to the bastion if desired"
  type        = list(string)
  default     = [""]
}

variable "service_account_name" {
  description = "Account ID for the service account"
  type        = string
  default     = "bastion-group"
}

variable "service_account_email" {
  description = "If set, the service account and its permissions will not be created. The service account being passed in should have at least the roles listed in the parent module `service_account_roles` variable so that logging and OS Login work as expected."
  default     = ""
  type        = string
}

variable "subnet" {
  description = "Self link for the subnet on which the Bastion should live. Can be private when using IAP"
  type        = string
}

variable "zone" {
  description = "The primary zone where the bastion host will live"
  type        = string
  default     = "us-central1-a"
}

variable "random_role_id" {
  description = "Enables role random id generation."
  type        = bool
  default     = true
}

variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
  default     = "asia-northeast1"
}

variable "autoscaling_enabled" {
  type        = bool
  default     = false
  description = "Creates an autoscaling for the managed instance group"
}

variable "min_replicas" {
  type        = number
  default     = 1
  description = "The minimum number of replicas that the autoscaling can scale down to. This cannot be less than 0."
}