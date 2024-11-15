terraform {
  backend "s3" {
    bucket = "helloworld-tf-state"
    key    = "terraform.tfstate"
    region = "us-west-2"    
  }
}

provider "aws" {
  region = var.region
}
