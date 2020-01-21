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
%{~ if length(imports) != 0}%{for key, value in imports}
    ${format("%-12s", key)} = yamldecode(file("${value}"))
%{~ endfor}%{endif}
  }
  globals = yamldecode(file("../../${org}/globals.yml"
}

data "aws_availability_zones" "current" {}
data "aws_caller_identity" "current" {}

output "config" {
  value = local.config
}