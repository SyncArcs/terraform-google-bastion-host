variable "name" {
  type        = string
  default     = "test"
  description = "Name of the resource. Provided by the client when the resource is created. "
}

variable "environment" {
  type        = string
  default     = "iap-tunneling"
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}
