resource "aws_launch_template" "eks_template" {
  name = "eks_launch_template"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted = true // Ephemeral storage will be encrypted
    }
  }

  metadata_options {  //metadata won't be acessible without token inside the cluster
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name      = "eks-managed-node"
      managedBy = "Terraform"
    }
  }
}
