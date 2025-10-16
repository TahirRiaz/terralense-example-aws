# Remote state from networking project
data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "your-terraform-state-bucket"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# Remote state from compute project
data "terraform_remote_state" "compute" {
  backend = "s3"

  config = {
    bucket = "your-terraform-state-bucket"
    key    = "compute/terraform.tfstate"
    region = "us-east-1"
  }
}

# Remote state from database project
data "terraform_remote_state" "database" {
  backend = "s3"

  config = {
    bucket = "your-terraform-state-bucket"
    key    = "database/terraform.tfstate"
    region = "us-east-1"
  }
}
