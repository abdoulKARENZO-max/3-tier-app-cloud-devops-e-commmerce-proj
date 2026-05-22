terraform {
  backend "s3" {
    bucket       = "terraform-backend-tws-263476283037" # your account ID here
    key          = "backend-locking"
    region       = "us-east-1"
    use_lockfile = true
  }
}
