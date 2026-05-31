terraform {
  backend "s3" {
    bucket = "bedrock-terraform-state-alt-soe-025-1507"
    key    = "project-bedrock/terraform.tfstate"
    region = "us-east-1"
  }
}
