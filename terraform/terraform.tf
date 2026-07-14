
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Real AWS backend (re-enable when applying against actual AWS):
  # backend "s3" {
  #   bucket       = "terraform-backend-tws-263476283037"
  #   key          = "backend-locking"
  #   region       = "us-east-1"
  #   use_lockfile = true
  # }

  backend "local" {
    path = "terraform.tfstate.floci"
  }
}
