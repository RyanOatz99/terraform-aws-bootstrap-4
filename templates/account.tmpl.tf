resource "aws_organizations_account" "${name}" {
  name      = "${name}"
  email     = "${email}"
  role_name = "crossaccount-admin"
  lifecycle {
    ignore_changes = [role_name]
  }
}