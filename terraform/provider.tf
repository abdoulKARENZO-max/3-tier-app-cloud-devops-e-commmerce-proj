locals {
  region          = "us-east-1"
  name            = "tws-eks-cluster"
  vpc_cidr        = "10.0.0.0/16"
  azs             = ["us-east-1c", "us-east-1d"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  tags = {
    example = local.name
  }
}

provider "aws" {
  region                      = local.region
  access_key                  = "floci"
  secret_key                  = "floci"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2         = "http://localhost:4566"
    eks         = "http://localhost:4566"
    iam         = "http://localhost:4566"
    sts         = "http://localhost:4566"
    s3          = "http://localhost:4566"
    elbv2       = "http://localhost:4566"
    autoscaling = "http://localhost:4566"
  }
}
