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
module "project-sandbox" {
  source         = "../"
  root_account   = module.root
  name           = "project"
  environment    = "sandbox"
  email          = "aws+project-sandbox@${local.domain}"
  region         = "us-east-1"
  sections       = local.standard_sections
}

module "project-dev" {
  source         = "../"
  root_account   = module.root
  name           = "project"
  environment    = "dev"
  email          = "aws+project-dev@${local.domain}"
  region         = "us-east-1"
  sections       = local.standard_sections
}

module "project-preprod" {
  source         = "../"
  root_account   = module.root
  name           = "project"
  environment    = "preprod"
  email          = "aws+project-preprod@${local.domain}"
  region         = "us-east-1"
  sections       = local.standard_sections
}

module "project-prod" {
  source         = "../"
  root_account   = module.root
  name           = "project"
  environment    = "prod"
  email          = "aws+project-prod@${local.domain}"
  region         = "us-east-1"
  sections       = local.standard_sections
}

output "instructions" {
  value = <<-EOF

    1. Run `aws-vault add ${local.org}` and enter the creds for the root/master
       AWS account. Then, run the following:
       cat <<EOF >> ~/.aws/config
    [profile ${local.org}]
    credential_process=aws-vault exec ${local.org} --json
    region = ${module.root.region}
    EOF
    2. Ensure a private s3 bucket exists in the root/master account:
       aws s3api create-bucket --acl private --bucket ${module.root.name}-${module.root.region}-tfstate --profile ${local.org}
    3. Ensure the bucket is locked down by running the following:
       (cd ${local.org} && terraform init && terraform apply)
    4. Run the following to create all subaccounts:
       (cd ${local.org}/subaccounts && terraform init && terraform apply)
    5. Follow the instructions from the output shown.

  EOF
}