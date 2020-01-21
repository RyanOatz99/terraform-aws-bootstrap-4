data "aws_organizations_organization" "${name}" {}
locals {
  org = data.aws_organizations_organization.${name}
}

output "config" {
  value = <<-CONFIG
    To enable web-based administration, install this: https://goo.gl/0QFjow
    Configure with this:
    [profile ${name}]
    aws_account_id = ${DOLLAR}{local.org.master_account_id}

    ${DOLLAR}{join("\n", [for account in local.org.accounts : <<-ACCOUNT
      [profile ${DOLLAR}{account.name}]
      role_arn = arn:aws:iam::${DOLLAR}{account.id}:role/admin
      source_profile = ${name}
    ACCOUNT
    if account.id != local.org.master_account_id && account.status == "ACTIVE"
    ])}EOF
  CONFIG
}
