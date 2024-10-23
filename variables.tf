variable "ec2_key_pair" {
  type        = string
  description = "Name of the EC2 key pair"
}

variable "s3_log_uri" {
  type        = string
  description = "S3 bucket for storing EMR logs"
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "AWS Region"
}

variable "s3_path_uri" {
  type        = string
  description = "S3 bucket for storing EMR config"
}
