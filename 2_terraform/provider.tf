provider "aws" {
  region = "us-west-2"
}

provider "time" {}
data "aws_region" "current" {}
