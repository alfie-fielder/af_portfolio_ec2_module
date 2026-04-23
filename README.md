# EC2 Module

This module creates an AWS EC2 instance with security-focused defaults, including IMDSv2 enforcement, encrypted EBS volumes, and detailed CloudWatch monitoring.

## Usage

```hcl
module "ec2" {
  source = "./modules/ec2"

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
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Security Defaults

This module is opinionated about security out of the box:

| Feature | Default |
|---------|---------|
| IMDSv2 | Enforced (`http_tokens = "required"`) |
| Root EBS encryption | Always enabled |
| Public IP | Disabled |
| Detailed monitoring | Enabled |
| EBS optimised | Enabled |
| Metadata hop limit | 1 (raise to 2 for containers) |

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
| `root_volume_delete_on_termination` | Whether to delete the root EBS volume on instance termination | `bool` | `true` | no |

### Metadata

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `metadata_hop_limit` | HTTP PUT response hop limit for IMDS requests. Use `2` when running containers | `number` | `1` | no |

### Tagging

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `tags` | A map of tags to assign to the instance | `map(string)` | `{}` | no |
| `volume_tags` | A map of tags to assign to the root EBS volume | `map(string)` | `{}` | no |

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

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.3.0` |
| AWS Provider | `>= 5.0.0` |