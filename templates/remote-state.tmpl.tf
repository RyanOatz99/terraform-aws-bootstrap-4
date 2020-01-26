# Get data from another terraform project by reading it's tfstate file.
data "terraform_remote_state" "${key}" {
  backend = "s3"
  config = {
    profile = "${profile}"
    region  = "${region}"
    bucket  = "${bucket}-tfstate"
    key     = "${statefile}.tfstate"
  }
}

# Make data from other project accessible under a shorter name.
locals {
  ${key} = data.terraform_remote_state.${key}.outputs
}