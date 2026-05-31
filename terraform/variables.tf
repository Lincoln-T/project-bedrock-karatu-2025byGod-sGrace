variable "region" {
  description = "AWS region for Project Bedrock"
  type        = string
  default     = "us-east-1"
}

variable "student_id" {
  description = "Student ID used to create a unique S3 bucket name"
  type        = string
}
