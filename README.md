# terraform-aws-bootstrap
> a terraform module to scaffold terraform projects for aws

## Assumptions

* You want to manage infrastructure for a large organization in AWS.
* You want to segregate workloads with sub-accounts for security & billing.
* You want to administer sub-accounts through role switching.
* You want a clean pattern for linking resources between sub-accounts, e.g.
  * ECR container registry sharing
  * VPC peering

## Example
Run `terraform init && terraform apply` in the [example directory](./example).