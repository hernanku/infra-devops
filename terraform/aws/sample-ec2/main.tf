# Instance IAM profile, roles and policies
resource "aws_iam_instance_profile" "asg_instance_profile" {
  name = "${var.project_name}-${var.application_name}-instance-profile-${var.environment}"
  role = aws_iam_role.asg_instance_role.name
}

resource "aws_iam_role" "asg_instance_role" {
  name = "${var.project_name}-${var.application_name}-instance-role-${var.environment}"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Sid    = ""
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
    }
  )
}

resource "aws_iam_policy" "asg_instance_s3_policy" {
  name        = "${var.project_name}-${var.application_name}-s3-policy-${var.environment}"
  description = "iam access policy for ${var.project_name} ${var.application_name} instance access to s3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "asg_s3_policy_attach" {
  role       = aws_iam_role.asg_instance_role.name
  policy_arn = aws_iam_policy.asg_instance_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "asg_ssm_policy_attach" {
  role       = aws_iam_role.asg_instance_role.name
  policy_arn = data.aws_iam_policy.asg_ssm_instance_policy.arn
}


resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for ${var.project_name} ${var.application_name} autoscaling"
  custom_suffix    = "${var.project_name}-${var.application_name}-${var.environment}"

  # Sometimes good sleep is required to have some IAM resources created before they can be used
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

# Security groups
resource "aws_security_group" "asg_sg" {
  name        = "${var.project_name}-${var.application_name}-sg-${var.environment}"
  description = "asg repo private security group"
  vpc_id      = data.aws_vpc.selected.id

  # Access from other security groups
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



module "s3_logging_bucket" {
  source  = "operatehappy/s3-bucket/aws"
  version = "1.2.0"
  name    = "${lower(local.s3_logging_bucket_name)}-logging"
  acl     = "log-delivery-write"

  force_destroy = true

  server_side_encryption_configuration = {
    sse_algorithm = "AES256"
  }
}


module "asg_elb" {
  source = "terraform-aws-modules/elb/aws"
  name   = "${var.project_name}-${var.application_name}-elb-${var.environment}"

  subnets         = [for s in data.aws_subnet.subnet_private_lists : s.id]
  security_groups = [aws_security_group.asg_sg.id]
  internal        = false

  listener     = var.asg_elb_listeners
  health_check = var.asg_elb_health_check

  tags = local.tags
}


module "asg_ec2" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name            = "${var.project_name}-${var.application_name}-asg-${var.environment}"
  use_name_prefix = false

  max_size                  = var.asg_max
  min_size                  = var.asg_min
  health_check_grace_period = var.asg_grace
  health_check_type         = var.asg_health_check_type
  wait_for_capacity_timeout = 0
  vpc_zone_identifier       = [for s in data.aws_subnet.subnet_private_lists : s.id]
  load_balancers            = [module.asg_elb.elb_name]
  service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn


  # launch template
  update_default_version = true

  // user_data_base64  = base64encode(local.user_data)
  ebs_optimized     = true
  enable_monitoring = false

  iam_instance_profile_arn = aws_iam_instance_profile.asg_instance_profile.arn
  // target_group_arns = [module.asg_elb.elb_arn]



  description            = "asg ec2 launch template for ${var.project_name}'s ${var.application_name} instances in ${var.environment}."

  // lt_name                = "${var.project_name}-${var.application_name}-lt-${var.environment}"
  // use_lt    = false
  // create_lt = false

  lc_name   = "${var.project_name}-${var.application_name}-lc-${var.environment}"
  use_lc    = true
  create_lc = true

  image_id      = var.asg_ami_id
  instance_type = var.asg_instance_type
  key_name      = var.asg_ssh_key_name
  // user_data_base64  = base64encode(local.user_data)

  block_device_mappings = var.asg_block_device_mappings

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  credit_specification = {
    cpu_credits = "standard"
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [aws_security_group.asg_sg.id]
    }
  ]

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = merge({ WhatAmI = "Instance" }, local.tags)
    },
    {
      resource_type = "volume"
      tags          = merge({ WhatAmI = "Volume" }, local.tags)
    }
  ]

  tags        = local.asg_tags
  tags_as_map = local.tags

}



