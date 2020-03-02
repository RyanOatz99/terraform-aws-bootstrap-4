locals {
  is_root = var.root_account == true
  name = "${local.is_root ? var.name : "${var.root_account.name}-${var.name}"}${var.environment != null ? "-${var.environment}" : ""}"
  root_path = "${path.root}/${local.name}"
  domain = var.domain == null ? "${var.environment != null ? "${var.environment}." : ""}${var.name}.${var.root_account.domain}" : var.domain
  crosslinked_sections = [
    for name, config in var.sections : name if config.crosslinked
  ]
  generated = "# GENERATED BY TERRAFORM, DO NOT EDIT"
}

// configure global config file for the root account
resource "local_file" "global_config" {
  count                = local.is_root ? 1 : 0
  filename             = "${path.root}/${local.name}/globals.yml"
  file_permission      = "0644"
  directory_permission = "0755"
  content = <<-EOF
    name: ${local.name}
    domain: ${local.domain}
  EOF
  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

// configure accounts to hold state for all accounts if this is a root module
resource "local_file" "accounts_config" {
  count                = local.is_root ? 1 : 0
  filename             = "${path.root}/${local.name}/subaccounts/config.tf"
  file_permission      = "0644"
  directory_permission = "0755"
  content = <<-EOF
    ${local.generated}
    ${templatefile("${path.module}/templates/provider.tmpl.tf", {
      profile = local.name
      region  = var.region
      alias   = null
    })}

    ${templatefile("${path.module}/templates/backend.tmpl.tf", {
      profile   = local.name
      region    = var.region
      bucket    = local.name
      statefile = "accounts"
    })}

    ${templatefile("${path.module}/templates/config.tmpl.tf", {
      DOLLAR = "$"
      name   = local.name
    })}
  EOF
}

// configure crosslink to hold state for all accounts if this is a root module
resource "local_file" "crosslink_config" {
  count                = local.is_root ? 1 : 0
  filename             = "${path.root}/crosslink/config.tf"
  file_permission      = "0644"
  directory_permission = "0755"
  content = <<-EOF
    ${local.generated}
    ${templatefile("${path.module}/templates/provider.tmpl.tf", {
      profile = local.name
      region  = var.region
      alias   = null
    })}

    ${templatefile("${path.module}/templates/backend.tmpl.tf", {
      profile   = local.name
      region    = var.region
      bucket    = local.name
      statefile = "crosslink"
    })}
  EOF
}

// configure subaccount under parent account
resource "local_file" "account" {
  count                = local.is_root ? 0 : 1
  filename             = "${path.root}/${var.root_account.name}/subaccounts/${local.name}.tf"
  file_permission      = "0644"
  directory_permission = "0755"
  content = <<-EOF
     ${local.generated}
     ${templatefile("${path.module}/templates/account.tmpl.tf", {
      name = local.name
      email = var.email
    })}
  EOF
}

// configure bootstrap file to create per-account s3 bucket/domain/etc
resource "local_file" "bootstrap" {
  filename             = "${local.root_path}/bootstrap.tf"
  file_permission      = "0644"
  directory_permission = "0755"
  content = <<-EOF
    ${local.generated}
    ${templatefile("${path.module}/templates/provider.tmpl.tf", {
      profile = local.name
      region  = var.region
      alias   = local.name
    })}

    ${templatefile("${path.module}/templates/bucket.tmpl.tf", {
      name   = local.name
      region = var.region
    })}

    ${templatefile("${path.module}/templates/backend.tmpl.tf", {
      profile   = local.is_root ? var.name : var.root_account.name
      region    = local.is_root ? var.region : var.root_account.region
      bucket    = local.is_root ? var.name : var.root_account.name
      statefile = local.name
    })}
    %{if local.is_root}
    # Create root domain that will control DNS for internal tooling on all accounts.
    ${templatefile("${path.module}/templates/dns.tmpl.tf", {
      provider = local.name
      domain   = local.domain
    })}

    ${templatefile("${path.module}/templates/cloudtrail.tmpl.tf", {
      provider = local.name
      bucket   = "${local.name}-security-cloudtrail"
      DOLLAR   = "$"
    })}

    # Ensure root/master account can create subaccounts
    resource "aws_organizations_organization" "main" {
      provider = aws.${local.name}
      aws_service_access_principals = [
        "cloudtrail.amazonaws.com"
      ]
    }
    %{else}
    # Account-level zone file for all DNS in this sub-account.
    ${templatefile("${path.module}/templates/dns.tmpl.tf", {
      provider = local.name
      domain   = local.domain
    })}

    ${templatefile("${path.module}/templates/dns-delegate.tmpl.tf", {
      domain      = local.domain
      root_name   = var.root_account.name
      root_domain = var.root_account.domain
    })}

    ${templatefile("${path.module}/templates/provider.tmpl.tf", {
      profile = var.root_account.name
      region  = var.root_account.region
      alias   = var.root_account.name
    })}
    %{endif~}
  EOF
}

// configure each section in the account
resource "local_file" "section_configs" {
  for_each             = var.sections
  filename             = "${local.root_path}/${each.key}/config.tf"
  file_permission      = "0644"
  directory_permission = "0755"
  content = <<-EOF
    ${local.generated}
    ${templatefile("${path.module}/templates/provider.tmpl.tf", {
      profile = local.name
      region  = var.region
      alias   = null
    })}

    ${templatefile("${path.module}/templates/locals.tmpl.tf", {
      name          = var.name
      domain        = local.domain
      region        = var.region
      environment   = var.environment
      secret_prefix = local.is_root ? "/${var.name}" : "/${var.root_account.name}-${var.name}"
      org           = local.is_root ? var.name : var.root_account.name
    })}
    %{for state in each.value.remote_states}
    ${templatefile("${path.module}/templates/remote-state.tmpl.tf", {
      profile   = local.name
      region    = var.region
      bucket    = local.name
      statefile = state
      key       = state
    })}
    %{endfor~}

    ${templatefile("${path.module}/templates/backend.tmpl.tf", {
      profile   = local.name
      region    = var.region
      bucket    = local.name
      statefile = each.key
    })}
  EOF
}

// load remote states into crosslink layer for all relevant sections
resource "local_file" "crosslink_sections" {
  count                = length(local.crosslinked_sections)
  filename             = "${path.root}/crosslink/${local.name}.tf"
  file_permission      = "0644"
  directory_permission = "0755"
  content = <<-EOF
    ${local.generated}
    %{for section in local.crosslinked_sections}
    ${templatefile("${path.module}/templates/remote-state.tmpl.tf", {
      profile   = local.name
      region    = var.region
      bucket    = local.name
      statefile = section
      key       = "${local.name}-${section}"
    })}
    %{endfor~}
  EOF
}