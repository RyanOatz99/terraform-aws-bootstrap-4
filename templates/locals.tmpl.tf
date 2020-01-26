locals {
  config = {
    name         = "${name}"
%{~ if environment != null}
    environment  = "${environment}"
%{~ endif}
%{~ if domain != null}
    domain       = "${domain}"
%{~ endif}
    region       = "${region}"
    account_id   = data.aws_caller_identity.current.account_id
    azs          = data.aws_availability_zones.current
  }
  globals = yamldecode(file("../../${org}/globals.yml"))
}

data "aws_availability_zones" "current" {}
data "aws_caller_identity" "current" {}

output "config" {
  value = local.config
}