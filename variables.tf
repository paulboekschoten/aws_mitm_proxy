variable "cert_email" {
  description = "email address used to obtain ssl certificate"
  type        = string
}

variable "route53_zone" {
  description = "the domain to use for the url"
  type        = string
}

variable "route53_subdomain" {
  description = "the subdomain of the url"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "instance_type" {
  description = "instance type"
  type        = string
  default     = "t2.medium"
}

variable "proxy_port" {
  description = "Server port for proxy requests."
  type        = number
  default     = 8080
}

variable "ssh_port" {
  description = "Server port for SSH requests."
  type        = number
  default     = 22
}

variable "environment_name" {
  description = "Name of the environment."
  type        = string
}

variable "owned_by" {
  description = "Owner of the resources."
  type        = string
}

variable "proxy_user" {
  description = "User for proxy authentication."
  type        = string    
}

variable "proxy_pass" {
  description = "Password for proxy authentication."
  type        = string
}

variable "mitm_tar_download_url" {
  description = "Download link of the mitm tar file."
  type        = string
}

variable "mitm_tar_name" {
  description = "Name of the tar file on the filesystem."
  type        = string
}