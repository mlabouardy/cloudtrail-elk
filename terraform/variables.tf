variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "key_name" {
  description = "SSH Key Pair"
  default     = "personal"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.xlarge"
}
