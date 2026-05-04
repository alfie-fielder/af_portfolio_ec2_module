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

  user_data                   = var.user_data_base64 != null ? null : var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  instance_initiated_shutdown_behavior = var.shutdown_behavior

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = var.metadata_hop_limit
    instance_metadata_tags      = "enabled"
  }

  maintenance_options {
    auto_recovery = "default"
  }

  dynamic "cpu_options" {
    for_each = var.cpu_core_count != null ? [1] : []
    content {
      core_count       = var.cpu_core_count
      threads_per_core = var.cpu_threads_per_core
    }
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = true
    kms_key_id            = var.root_volume_kms_key_id
    delete_on_termination = var.root_volume_delete_on_termination
    tags                  = var.volume_tags
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type != null ? ebs_block_device.value.volume_type : "gp3"
      iops                  = ebs_block_device.value.iops
      throughput            = ebs_block_device.value.throughput
      encrypted             = true
      kms_key_id            = ebs_block_device.value.kms_key_id != null ? ebs_block_device.value.kms_key_id : var.root_volume_kms_key_id
      delete_on_termination = ebs_block_device.value.delete_on_termination != null ? ebs_block_device.value.delete_on_termination : true
      snapshot_id           = ebs_block_device.value.snapshot_id
      tags                  = ebs_block_device.value.tags
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [ami]

    precondition {
      condition     = var.ami != null && var.ami != ""
      error_message = "ami must be a non-empty string. Ensure the correct AMI ID is passed for this region."
    }

    precondition {
      condition     = !(var.user_data != null && var.user_data_base64 != null)
      error_message = "Only one of user_data or user_data_base64 may be set, not both."
    }

    precondition {
      condition     = var.cpu_core_count == null || var.cpu_threads_per_core != null
      error_message = "cpu_threads_per_core must be set if cpu_core_count is set."
    }
  }
}
