# EC2 Module

This module creates an AWS EC2 instance with security-focused defaults, including IMDSv2 enforcement, encrypted EBS volumes, and detailed CloudWatch monitoring.

## Usage

```hcl
module "ec2" {
  source = "git::https://github.com/alfie-fielder/af_portfolio_ec2_module.git?ref=v2.0.0"

  instance_type          = "t3.micro"
  ami                    = "ami-0c55b159cbfafe1f0"
  subnet_id              = "subnet-12345678"
  vpc_security_group_ids = ["sg-12345678"]

  key_name             = "my-key"
  iam_instance_profile = "my-instance-profile"

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }

  volume_tags = {
    Name        = "my-instance-root"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### With additional EBS volumes and CMK encryption

```hcl
module "ec2" {
  source = "git::https://github.com/alfie-fielder/af_portfolio_ec2_module.git?ref=v2.0.0"

  instance_type          = "t3.large"
  ami                    = "ami-0c55b159cbfafe1f0"
  subnet_id              = "subnet-12345678"
  vpc_security_group_ids = ["sg-12345678"]

  root_volume_kms_key_id = "arn:aws:kms:eu-west-2:123456789012:key/mrk-abc123"

  volume_tags = {
    Name        = "my-instance-root"
    Environment = "prod"
    ManagedBy   = "terraform"
  }

  ebs_block_devices = [
    {
      device_name = "/dev/sdb"
      volume_size = 100
      volume_type = "gp3"
      throughput  = 250
      tags = {
        Name        = "my-instance-data"
        Environment = "prod"
        ManagedBy   = "terraform"
      }
    }
  ]

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

### With CPU options (licensing control)

```hcl
module "ec2" {
  source = "git::https://github.com/alfie-fielder/af_portfolio_ec2_module.git?ref=v2.0.0"

  instance_type          = "r5.4xlarge"
  ami                    = "ami-0c55b159cbfafe1f0"
  subnet_id              = "subnet-12345678"
  vpc_security_group_ids = ["sg-12345678"]

  # Reduce visible vCPU count for Oracle licensing
  cpu_core_count       = 8
  cpu_threads_per_core = 1

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
  }

  volume_tags = {
    Name        = "my-instance-root"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

## Breaking Changes

### v2.0.0
- `volume_tags` now applies **only to the root volume**. Additional EBS volumes are tagged individually via the `tags` attribute on each `ebs_block_devices` object. If you were relying on `volume_tags` to tag all volumes, you must now set `tags` per volume in `ebs_block_devices`.

## Security Defaults

This module is opinionated about security out of the box:

| Feature | Default |
|---------|---------|
| IMDSv2 | Enforced (`http_tokens = "required"`) |
| Root EBS encryption | Always enabled |
| Additional EBS encryption | Always enabled |
| Public IP | Disabled |
| Detailed monitoring | Enabled |
| EBS optimised | Enabled |
| Metadata hop limit | 1 (raise to 2 for containers) |
| Instance metadata tags | Enabled |
| Auto recovery | Enabled |

## Inputs

### Instance

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `instance_type` | The type of instance to launch | `string` | `"t2.micro"` | no |
| `ami` | The AMI ID to use for the instance | `string` | | yes |
| `key_name` | The name of the EC2 key pair to associate with the instance | `string` | `null` | no |
| `iam_instance_profile` | The name or ARN of an IAM instance profile to associate with the instance | `string` | `null` | no |
| `ebs_optimized` | Whether to enable EBS optimisation on the instance | `bool` | `true` | no |
| `monitoring` | Whether to enable detailed CloudWatch monitoring | `bool` | `true` | no |
| `user_data` | Raw user data script. Mutually exclusive with `user_data_base64` | `string` | `null` | no |
| `user_data_base64` | Base64-encoded user data. Mutually exclusive with `user_data` | `string` | `null` | no |
| `user_data_replace_on_change` | Whether to replace the instance when user data changes | `bool` | `false` | no |
| `shutdown_behavior` | Instance behaviour on OS-initiated shutdown. Valid values: `stop`, `terminate` | `string` | `"stop"` | no |

### Networking

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `subnet_id` | The ID of the subnet to launch the instance in | `string` | | yes |
| `vpc_security_group_ids` | A list of security group IDs to associate with the instance | `list(string)` | | yes |
| `associate_public_ip_address` | Whether to associate a public IP address with the instance | `bool` | `false` | no |

### Root Volume

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `root_volume_size` | The size of the root EBS volume in GiB | `number` | `20` | no |
| `root_volume_type` | The type of the root EBS volume (`gp2`, `gp3`, `io1`, `io2`) | `string` | `"gp3"` | no |
| `root_volume_kms_key_id` | ARN of the KMS key for root volume encryption. If null, uses the AWS-managed key (`aws/ebs`) | `string` | `null` | no |
| `root_volume_delete_on_termination` | Whether to delete the root EBS volume on instance termination | `bool` | `true` | no |

### Additional EBS Volumes

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `ebs_block_devices` | A list of additional EBS volumes to attach to the instance | `list(object)` | `[]` | no |

Each object in `ebs_block_devices` supports the following attributes:

| Attribute | Description | Type | Default | Required |
|-----------|-------------|------|---------|:--------:|
| `device_name` | The device name, e.g. `/dev/sdb` | `string` | | yes |
| `volume_size` | Size in GiB | `number` | | yes |
| `volume_type` | `gp2`, `gp3`, `io1`, `io2` | `string` | `"gp3"` | no |
| `iops` | Required for `io1`/`io2`, optional for `gp3` | `number` | `null` | no |
| `throughput` | MiB/s throughput. `gp3` only | `number` | `null` | no |
| `kms_key_id` | KMS key ARN. Falls back to `root_volume_kms_key_id` if not set | `string` | `null` | no |
| `delete_on_termination` | Whether to delete the volume on instance termination | `bool` | `true` | no |
| `snapshot_id` | Snapshot ID to restore from | `string` | `null` | no |
| `tags` | A map of tags to assign to this volume | `map(string)` | `null` | no |

### CPU Options

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `cpu_core_count` | Number of CPU cores. Used to reduce vCPU count for licensing purposes. Must be set alongside `cpu_threads_per_core` | `number` | `null` | no |
| `cpu_threads_per_core` | Threads per CPU core. Set to `1` to disable hyperthreading. Must be set alongside `cpu_core_count` | `number` | `null` | no |

### Metadata

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `metadata_hop_limit` | HTTP PUT response hop limit for IMDS requests. Use `2` when running containers | `number` | `1` | no |

### Tagging

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `tags` | A map of tags to assign to the instance | `map(string)` | `{}` | no |
| `volume_tags` | A map of tags to assign to the root EBS volume only | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | The ID of the EC2 instance |
| `arn` | The ARN of the EC2 instance |
| `private_ip` | The private IP address of the EC2 instance |
| `public_ip` | The public IP address of the EC2 instance |
| `private_dns` | The private DNS name of the EC2 instance |
| `public_dns` | The public DNS name of the EC2 instance |
| `availability_zone` | The availability zone the instance was launched in, derived from the subnet |
| `subnet_id` | The subnet ID the instance was launched in |
| `instance_state` | The current state of the instance |

## Notes

- **AMI lifecycle** — the module ignores changes to the `ami` attribute after initial creation. AMI updates should be handled through a reprovisioning process rather than a Terraform replace.
- **Availability zone** — the AZ is derived from the subnet and is not a configurable input. Use the `availability_zone` output to reference it downstream.
- **IMDSv2** — all instances launched by this module require IMDSv2. If your application code uses the metadata service, ensure it uses a session-oriented approach (AWS SDKs v2+ handle this automatically).
- **EBS encryption** — all volumes (root and additional) are always encrypted. If `root_volume_kms_key_id` is not set, the AWS-managed key (`aws/ebs`) is used. Additional volumes fall back to `root_volume_kms_key_id` if no per-volume key is specified.
- **EBS tagging** — `volume_tags` applies only to the root volume. Additional volumes are tagged individually via the `tags` attribute in each `ebs_block_devices` object, giving full per-volume tag control.
- **CPU options** — `cpu_core_count` and `cpu_threads_per_core` must be set together. If neither is set, the instance uses the default vCPU count for the instance type. This is primarily useful for reducing licensing costs on software licensed per-vCPU (e.g. Oracle, Windows Server).
- **User data** — `user_data` and `user_data_base64` are mutually exclusive. By default, changes to user data do not replace the instance — set `user_data_replace_on_change = true` to enable replacement.

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.3.0` |
| AWS Provider | `>= 5.0.0` |
