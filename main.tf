provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  email     = var.cloudflare_email
  api_token = var.cloudflare_api_key
}

resource "aws_s3_bucket" "site" {
  bucket = var.site_domain
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_acl" "site" {
  bucket = aws_s3_bucket.site.id

  acl = "public-read"
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.site.arn,
          "${aws_s3_bucket.site.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket" "www" {
  bucket = "www.${var.site_domain}"
}

resource "aws_s3_bucket_acl" "www" {
  bucket = aws_s3_bucket.www.id

  acl = "private"
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id

  redirect_all_requests_to {
    host_name = var.site_domain
  }
}

data "cloudflare_zones" "domain" {
  filter {
    name = var.site_domain
  }
}

resource "cloudflare_record" "site_cname" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.site_domain
  value   = aws_s3_bucket_website_configuration.site.website_endpoint
  type    = "CNAME"

  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "www"
  value   = var.site_domain
  type    = "CNAME"

  ttl     = 1
  proxied = true
}
#backend state to s3
terraform {
  backend "s3" {
    bucket = "terraform-iac-state-backup"
    key    = "learn-terraform-cloudflare-static-website/terraform.tfstate"
    region = "us-east-1"
  }
}

#First, add a page rule to the main.tf file to convert any http:// request to https:// using a 301 redirect.
resource "cloudflare_page_rule" "https" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  target  = "*.${var.site_domain}/*"
  actions {
    always_use_https = true
  }
}

#Next, add another page rule to the main.tf file to temporarily redirect <your-domain>/learn to the Terraform tutorial page, where your-domain is your domain name.
resource "cloudflare_page_rule" "redirect-to-github" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  target  = "${var.site_domain}/github"
  actions {
    forwarding_url {
      status_code = 302
      url         = "https://github.com/ellipsis-me?tab=repositories"
    }
  }
}

#redirect to linkedin
resource "cloudflare_page_rule" "redirect-to-linkedin" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  target  = "${var.site_domain}/linkedin"
  actions {
    forwarding_url {
      status_code = 302
      url         = "https://www.linkedin.com/in/fernando-anjos-8936671a3/"
    }
  }
}

