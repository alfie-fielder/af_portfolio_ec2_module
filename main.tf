resource "aws_instance" "ec2" {
  instance_type = var.instance_type
  ami           = var.ami

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = var.associate_public_ip_address

  key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile

  ebs_optimized = var.ebs_optimized
  monitoring    = var.monitoring

  user_data        = var.user_data_base64 != null ? null : var.user_data
  user_data_base64 = var.user_data_base64

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = var.metadata_hop_limit
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = true
    delete_on_termination = var.root_volume_delete_on_termination
  }

  tags        = var.tags
  volume_tags = var.volume_tags

  lifecycle {
    ignore_changes = [ami]
  }
}