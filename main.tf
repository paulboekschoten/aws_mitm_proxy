terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.29.0"
    }
    # acme = {
    #   source  = "vancluever/acme"
    #   version = "2.8.0"
    # }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Name = var.environment_name
      OwnedBy = var.owned_by
    }
  }
}

# provider "acme" {
#   #server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
#   server_url = "https://acme-v02.api.letsencrypt.org/directory"
# }

## resources
# RSA key of size 4096 bits
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# store private ssh key locally
resource "local_file" "sshkey" {
  content         = tls_private_key.rsa_4096.private_key_pem
  filename        = "${path.module}/proxysshkey.pem"
  file_permission = "0600"
}

# key pair
resource "aws_key_pair" "proxy" {
  key_name   = "paul-proxy"
  public_key = tls_private_key.rsa_4096.public_key_openssh
}

# security group
resource "aws_security_group" "sg_proxy" {
  name = "sg_proxy"
}

# sg rule all outbound
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.sg_proxy.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# sg rule ssh inbound
resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.sg_proxy.id

  from_port   = var.ssh_port
  to_port     = var.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# sg rule proxy inbound
resource "aws_security_group_rule" "allow_proxy_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.sg_proxy.id

  from_port   = var.proxy_port
  to_port     = var.proxy_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# fetch ubuntu ami id for version 22.04
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# EC2 instance
resource "aws_instance" "proxy" {
  ami                    = data.aws_ami.ubuntu.image_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.proxy.key_name
  vpc_security_group_ids = [aws_security_group.sg_proxy.id]
  
  user_data = templatefile("${path.module}/scripts/cloud-init.tpl", {
#      proxy_host            = aws_route53_record.www.name
      proxy_user            = var.proxy_user
      proxy_pass            = var.proxy_pass
      mitm_tar_download_url = var.mitm_tar_download_url
      mitm_tar_name         = var.mitm_tar_name
#      proxy_cert            = base64encode("${acme_certificate.certificate.private_key_pem}${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}")
  })
}

# create public ip
resource "aws_eip" "eip_proxy" {
  domain = "vpc"
}

# associate public ip with instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.proxy.id
  allocation_id = aws_eip.eip_proxy.id
}

## route53 fqdn
# fetch zone
# data "aws_route53_zone" "selected" {
#   name         = var.route53_zone
#   private_zone = false
# }
# # create record
# resource "aws_route53_record" "www" {
#   zone_id = data.aws_route53_zone.selected.zone_id
#   name    = "${var.route53_subdomain}.${data.aws_route53_zone.selected.name}"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_eip.eip_proxy.public_ip]
# }

# ## certficate let's encrypt
# # create auth key
# resource "tls_private_key" "cert_private_key" {
#   algorithm = "RSA"
# }

# # register
# resource "acme_registration" "registration" {
#   account_key_pem = tls_private_key.cert_private_key.private_key_pem
#   email_address   = var.cert_email
# }
# # get certificate
# resource "acme_certificate" "certificate" {
#   account_key_pem = acme_registration.registration.account_key_pem
#   common_name     = aws_route53_record.www.fqdn
#   #subject_alternative_names = ["*.${aws_route53_record.www.name}"]

#   dns_challenge {
#     provider = "route53"

#     config = {
#       AWS_HOSTED_ZONE_ID = data.aws_route53_zone.selected.zone_id
#     }
#   }
# }