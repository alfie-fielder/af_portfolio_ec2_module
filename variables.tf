variable "instance_type" {
  description = "The type of instance to launch"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = can(regex("^[a-z][0-9][a-z]?\\.[a-z0-9]+$", var.instance_type))
    error_message = "instance_type must be a valid EC2 instance type (e.g. t3.micro, m5.large)."
  }
}

variable "ami" {
  description = "The AMI ID to use for the instance"
  type        = string

  validation {
    condition     = can(regex("^ami-[a-f0-9]+$", var.ami))
    error_message = "ami must be a valid AMI ID starting with 'ami-'."
  }
}

variable "key_name" {
  description = "The name of the EC2 key pair to associate with the instance. Set to null for no key pair."
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "The name or ARN of an IAM instance profile to associate with the instance."
  type        = string
  default     = null
}

variable "ebs_optimized" {
  description = "Whether to enable EBS optimisation on the instance."
  type        = bool
  default     = true
}

variable "monitoring" {
  description = "Whether to enable detailed CloudWatch monitoring on the instance."
  type        = bool
  default     = true
}

variable "user_data" {
  description = "Raw user data script to pass to the instance. Mutually exclusive with user_data_base64."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64-encoded user data to pass to the instance. Use this for binary content. Mutually exclusive with user_data."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in. The availability zone is derived from the subnet."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with the instance."
  type        = list(string)
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance."
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "The size of the root EBS volume in GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "root_volume_size must be between 8 and 16384 GiB."
  }
}

variable "root_volume_type" {
  description = "The type of the root EBS volume. Valid values: gp2, gp3, io1, io2."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.root_volume_type)
    error_message = "root_volume_type must be one of: gp2, gp3, io1, io2."
  }
}

variable "root_volume_delete_on_termination" {
  description = "Whether to delete the root EBS volume when the instance is terminated."
  type        = bool
  default     = true
}

variable "metadata_hop_limit" {
  description = "The HTTP PUT response hop limit for instance metadata requests. 1 is recommended for most cases; increase to 2 if running containers."
  type        = number
  default     = 1

  validation {
    condition     = var.metadata_hop_limit >= 1 && var.metadata_hop_limit <= 64
    error_message = "metadata_hop_limit must be between 1 and 64."
  }
}

variable "tags" {
  description = "A map of tags to assign to the instance."
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "A map of tags to assign to the root EBS volume."
  type        = map(string)
  default     = {}
}

variable "user_data_replace_on_change" {
  description = "Whether to replace the instance when user_data changes. Set to true to force replacement; false to ignore changes."
  type        = bool
  default     = false
}

variable "shutdown_behavior" {
  description = "The behaviour when the instance is shut down from the OS. Valid values: stop, terminate."
  type        = string
  default     = "stop"

  validation {
    condition     = contains(["stop", "terminate"], var.shutdown_behavior)
    error_message = "shutdown_behavior must be either 'stop' or 'terminate'."
  }
}

variable "root_volume_kms_key_id" {
  description = "The ARN of the KMS key to use for root EBS volume encryption. If null, uses the AWS-managed key (aws/ebs)."
  type        = string
  default     = null
}

variable "ebs_block_devices" {
  description = <<-EOT
    A list of additional EBS volumes to attach to the instance.
    Each object supports the following attributes:
      - device_name           (required) : The device name, e.g. /dev/sdb.
      - volume_size           (required) : Size in GiB.
      - volume_type           (optional) : gp2, gp3, io1, io2. Defaults to gp3.
      - iops                  (optional) : Required for io1/io2; optional for gp3.
      - throughput            (optional) : MiB/s throughput. gp3 only.
      - kms_key_id            (optional) : KMS key ARN. Falls back to root_volume_kms_key_id if not set.
      - delete_on_termination (optional) : Defaults to true.
      - snapshot_id           (optional) : Snapshot to restore from.
  EOT
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = optional(string)
    iops                  = optional(number)
    throughput            = optional(number)
    kms_key_id            = optional(string)
    delete_on_termination = optional(bool)
    snapshot_id           = optional(string)
    tags                  = optional(map(string))
  }))
  default = []
}

variable "cpu_core_count" {
  description = "The number of CPU cores. Used to reduce vCPU count for licensing purposes. Must be set alongside cpu_threads_per_core."
  type        = number
  default     = null
}

variable "cpu_threads_per_core" {
  description = "The number of threads per CPU core. Set to 1 to disable hyperthreading. Must be set alongside cpu_core_count."
  type        = number
  default     = null

  validation {
    condition     = var.cpu_core_count == null || var.cpu_threads_per_core != null
    error_message = "cpu_threads_per_core must be set when cpu_core_count is set."
  }
}
