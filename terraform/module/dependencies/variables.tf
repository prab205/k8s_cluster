variable "ingress_ports" {
  description = "contains ports for the ingress rules"
  type        = list(number)
  default     = [22, 80, 443]
  sensitive   = false
}

variable "source_cidr_block" {
  description = "List of cidr_block to open"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}