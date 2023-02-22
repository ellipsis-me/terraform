variable "aws_region" {
  type        = string
  description = "The AWS region to put the bucket into"
  default     = "us-east-1"
}

variable "site_domain" {
  type        = string
  description = "The domain name to use for the static site"
}

variable "cloudflare_email" {
  type        = string
  description = "e-mail cloudflare"
  default     = ""
  sensitive   = true
}

variable "cloudflare_api_key" {
  type        = string
  description = "API Token"
  default     = ""
  sensitive   = true
}