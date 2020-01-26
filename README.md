# terraform-aws-bootstrap
> a terraform module to scaffold terraform projects for aws

## Assumptions

* You want to manage infrastructure for a large organization in AWS.
* You want to segregate workloads with sub-accounts for security & billing.
* You want to administer sub-accounts through role switching.
* You want a clean pattern for linking resources between sub-accounts, e.g.
  * ECR container registry sharing
  * VPC peering
* You want control of DNS for internal-facing tools (e.g. ci/cd, monitoring
  dashboards, etc) to be entirely delegated to each each sub-account using
  Route53. _PRs welcome for other providers._

## Example
Run `terraform init && terraform apply` in the [example directory](./example).