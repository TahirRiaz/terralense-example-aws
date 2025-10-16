# Remote state from networking project
data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "your-terraform-state-bucket"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}
