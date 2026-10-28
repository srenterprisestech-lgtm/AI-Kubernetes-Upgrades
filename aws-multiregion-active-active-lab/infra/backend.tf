terraform {
  backend "s3" {
    key          = "aws-multiregion-active-active-lab/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}
