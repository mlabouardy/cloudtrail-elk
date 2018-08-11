provider "aws" {
  region = "${var.aws_region}"
}

data "aws_ami" "elk" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["elk-stack-6.2.4"]
  }
}

resource "aws_security_group" "elk_sg" {
  name        = "elk_sg"
  description = "Allow traffic on elasticsearch & kibana ports"

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "9200"
    to_port     = "9200"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "5601"
    to_port     = "5601"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name   = "elk_sg"
    Author = "mlabouardy"
    Tool   = "Terraform"
  }
}

resource "aws_iam_role_policy" "cloudtrail_bucket_access_policy" {
  name = "CloudTrailEventsBucketFullAccessPolicy"
  role = "${aws_iam_role.cloudtrail_bucket_access_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::cloudtrail-demo-2018"
    }
  ]
}
EOF
}

resource "aws_iam_role" "cloudtrail_bucket_access_role" {
  name = "CloudTrailEventsBucketFullAccessRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "cloudtrail_bucket_access_profile" {
  name = "cloudtrail_bucket_access_profile"
  role = "${aws_iam_role.cloudtrail_bucket_access_role.name}"
}

resource "aws_instance" "elk" {
  key_name             = "${var.key_name}"
  instance_type        = "${var.instance_type}"
  ami                  = "${data.aws_ami.elk.id}"
  security_groups      = ["${aws_security_group.elk_sg.name}"]
  iam_instance_profile = "${aws_iam_instance_profile.cloudtrail_bucket_access_profile.name}"

  root_block_device {
    volume_size = 100
  }

  tags {
    Name   = "elk"
    Author = "mlabouardy"
    Tool   = "Terraform"
  }
}
