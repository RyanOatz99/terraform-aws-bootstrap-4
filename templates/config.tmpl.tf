data "aws_organizations_organization" "${name}" {}
locals {
  org = data.aws_organizations_organization.${name}
  profiles = join("\n", [for account in local.org.accounts : <<-EOF
    [${DOLLAR}{account.name}]
    role_arn = arn:aws:iam::${DOLLAR}{account.id}:role/admin
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
    To enable command line administration with awscli/terraform, run this:
    cat <<EOF >> ~/.aws/credentials
    [${name}]
    aws_access_key_id = ACCESS_KEY
    aws_secret_access_key = SECRET_ACCESS_KEY

    ${DOLLAR}{local.profiles}
    EOF
  CONFIG
}
