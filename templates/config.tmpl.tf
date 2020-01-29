data "aws_organizations_organization" "${name}" {}
locals {
  org = data.aws_organizations_organization.${name}
  profiles = join("\n", [for account in local.org.accounts : <<-EOF
    [${DOLLAR}{account.name}]
    role_arn = arn:aws:iam::${DOLLAR}{account.id}:role/crossaccount-admin
    source_profile = ${name}
  EOF
  if account.id != local.org.master_account_id && account.status == "ACTIVE"
  ])
}

output "role-switching-config" {
  value = <<-CONFIG
    To enable web-based administration, install this: https://goo.gl/0QFjow
    Configure with this:
    [${name}]
    aws_account_id = ${DOLLAR}{local.org.master_account_id}

    ${DOLLAR}{local.profiles}
  CONFIG
}

output "awscli-credentials" {
  value = <<-CONFIG
    To enable command line access with aws-vault/awscli/terraform, run this:
    cat <<EOF >> ~/.aws/config
    ${DOLLAR}{local.profiles}
    EOF
  CONFIG
}
