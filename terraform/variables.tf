variable "aws_region" {
  description = "AWS Region to use"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Type of instance to spawn"
  type        = string
  default     = ""
}

variable "no_of_nodes" {
  description = "Total number of nodes including master node"
  type        = string
  default     = "2"
}

variable "instance_type" {
  description = "Type of instance to spawn"
  type        = string
  default     = "t2.medium"
}

variable "ssh_public_key_path" {
  description = "Path to your public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Path to your private key file"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ansible_directory" {
  description = "Location of ansible inventory file to generate"
  type        = string
  default     = "../ansible"
}