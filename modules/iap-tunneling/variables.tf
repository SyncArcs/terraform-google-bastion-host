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
  default     = "SyncArcs"
  description = "ManagedBy, eg 'SyncArcs'."
}

variable "repository" {
  type        = string
  default     = "https://github.com/SyncArcs/terraform-google-bastion-host"
  description = "Terraform current module repo"
}

variable "network" {
  description = "Self link of the network to attach the firewall to."
  type        = string
}

variable "service_accounts" {
  description = "Service account emails associated with the instances to allow SSH from IAP. Exactly one of service_accounts or network_tags should be specified."
  type        = list(string)
  default     = []
}

variable "network_tags" {
  description = "Network tags associated with the instances to allow SSH from IAP. Exactly one of service_accounts or network_tags should be specified."
  type        = list(string)
  default     = []
}

variable "instances" {
  type = list(object({
    name = string
    zone = string
  }))
  description = "Names and zones of the instances to allow SSH from IAP."
}

variable "members" {
  description = "List of IAM resources to allow using the IAP tunnel."
  type        = list(string)

}

variable "additional_ports" {
  description = "A list of additional ports/ranges to open access to on the instances from IAP."
  type        = list(string)
  default     = []
}

variable "create_firewall_rule" {
  type        = bool
  description = "If we need to create the firewall rule or not."
  default     = true
}