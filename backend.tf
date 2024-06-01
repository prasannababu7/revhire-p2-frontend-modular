terraform {
  backend "s3" {
    bucket         = "revhire-tf-state-bucket-dev-1"
    key            = "./terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}