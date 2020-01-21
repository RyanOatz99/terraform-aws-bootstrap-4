data "terraform_remote_state" "${key}" {
  backend = "s3"
  config = {
    profile = "${profile}"
    region  = "${region}"
    bucket  = "${bucket}-tfstate"
    key     = "${statefile}.tfstate"
  }
}

locals {
  ${key} = data.terraform_remote_state.${key}.outputs
}