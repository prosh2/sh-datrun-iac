terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "remote" {
    hostname     = "roronoa.scalr.io"
    organization = "env-v0od6uicoc86gsnsf"

    workspaces {
      name = "sh-datrun-iac-aws"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-1"
}
