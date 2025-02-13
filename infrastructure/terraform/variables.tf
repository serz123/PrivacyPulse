# -----------------------------------------------------------------------------
# File: variables.tf
# Description: Declares variables and local values used throughout the Terraform 
#              configuration to enable dynamic and flexible infrastructure management.
#
# Author: Mats Loock <mats.loock@lnu.se>
# Date: 2024-10-24
#
# Usage:
# - Variables should be set according to your environment's requirements.
# - Defaults are provided for ease of setup in common scenarios.
# -----------------------------------------------------------------------------

# The name of the primary key pair to use on the server
variable "primary_key_pair_name" {
  description = "The name of the primary key pair to put on the server"
  type        = string
}

# The file path to the primary private key for authentication
variable "primary_key_path" {
  description = "The path to the primary private key to use for authentication"
  type        = string
}

# Local value to store the content of the primary private key file
locals {
  primary_private_key = file(var.primary_key_path)
}

# The name of the external network
variable "external_network_name" {
  description = "External network name"
  type        = string
  default     = "public"
}

# A string containing CIDR range for the network
variable "subnet_cidr" {
  description = "String containing CIDR range for the network"
  type = string
  default = "192.168.98.0/24"
}

# The image name of the server to be used, with a default value
variable "image_name" {
  description = "Server image"
  type        = string
  # default     = "Ubuntu minimal 24.04.1 autoupgrade"
  default = "Ubuntu server 22.04.4"
}
