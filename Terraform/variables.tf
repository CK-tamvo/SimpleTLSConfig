# VPC variables
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "VPC for TLS"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# EC2 variables
variable "ec2_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "Web Server"
}

variable "ec2_instance_type" {
  description = "Type of the EC2 instance"
  type        = string
  default     = "t2.medium"
}

variable "ec2_key_name" {
  description = "Name of the key pair to use for the EC2 instance"
  type        = string
  default     = "my_key"
}

variable "ec2_ami" {
  description = "AMI ID for EC2"
  type        = string
  default     = "ami-005fc0f236362e99f" // Ubuntu 22.04 by default
}