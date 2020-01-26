locals {
  org    = "acme"
  domain = "acme.com"
  standard_sections = {
    foundation = {
      remote_states = []
      crosslinked   = true
    }
    environment = {
      remote_states = [
        "foundation"
      ]
      crosslinked = false
    }
  }
}

module "root" {
  source         = "../"
  root_account   = true
  region         = "us-east-1"
  name           = local.org
  email          = "aws@${local.domain}"
  domain         = local.domain
}

module "shared" {
  source         = "../"
  root_account   = module.root
  name           = "shared"
  email          = "aws+shared@${local.domain}"
  region         = "us-east-1"
}

module "security" {
  source         = "../"
  root_account   = module.root
  name           = "security"
  email          = "aws+security@${local.domain}"
  region         = "us-east-1"
}

// these will all become one module with a for_each when this lands:
// https://github.com/hashicorp/terraform/issues/10462
module "demo-sandbox" {
  source         = "../"
  root_account   = module.root
  name           = "demo"
  environment    = "sandbox"
  email          = "aws+demo-sandbox@${local.domain}"
  region         = "us-east-1"
  sections       = local.standard_sections
}

module "demo-dev" {
  source         = "../"
  root_account   = module.root
  name           = "demo"
  environment    = "dev"
  email          = "aws+demo-dev@${local.domain}"
  region         = "us-east-1"
  sections       = local.standard_sections
}

module "demo-preprod" {
  source         = "../"
  root_account   = module.root
  name           = "demo"
  environment    = "preprod"
  email          = "aws+demo-preprod@${local.domain}"
  region         = "us-east-1"
  sections       = local.standard_sections
}

module "demo-prod" {
  source         = "../"
  root_account   = module.root
  name           = "demo"
  environment    = "prod"
  email          = "aws+demo-prod@${local.domain}"
  region         = "us-east-1"
  sections       = local.standard_sections
}

output "instructions" {
  value = <<-EOF

    1. Configure an awscli profile named `${local.org}` that has administrative
       access to your root/master AWS account.
    2. Ensure a private s3 bucket named `${local.org}-tfstate` exists in the
       root/master account. You can run the following to create it:
       aws s3api create-bucket --acl private --bucket ${local.org}-tfstate --profile ${local.org}
    3. Ensure the bucket is locked down by running the following:
       (cd ${local.org} && terraform init && terraform apply)
    4. Run the following to create all subaccounts:
       (cd ${local.org}/subaccounts && terraform init && terraform apply)
    5. Follow the instructions from the output shown.

  EOF
}