variable "parent" {
  type = any
  default = null
  description = <<-EOF
    A reference to the outputs from this module itself, should point to the
    root or master account. This controls templating for the generated files.
  EOF
}

variable "name" {
  type = string
  description = <<-EOF
    Name of the account being managed. Ideally one word, short, lowercase.
  EOF
}

variable "environment" {
  type = string
  default = null
  description = <<-EOF
    Logical environment account lives in (e.g. sandbox, dev, preprod, prod).
  EOF
}

variable "email" {
  type = string
  description = <<-EOF
    Email address associated with the account.
  EOF
}

variable "region" {
  type = string
  description = <<-EOF
    Region for account.
  EOF
}

variable "domain" {
  type = string
  default = null
  description = <<-EOF
    Domain associated with this account. Typically for operator and developer
    facing interfaces. When not explictly configured, it will be generated using
    the name / environment and parent domain.
  EOF
}

variable "sections" {
  type = map(object({
    remote_states = list(string)
    crosslinked = bool
    imports = map(string)
  }))
  default = {}
  description = <<-EOF
    A map of discrete terraform projects to be created within this account.
    Useful for segregating terraform configurations by lifecycle. For example,
    a section titled "foundation" can contain long-lived resources like VPCs
    and a section titled "environment" can contain the resources deployed into
    it.

    remote_states:
      an array of other section names in this account whose terraform outputs
      should be made accessible to this section via a remote state backend.

    crosslinked:
      boolean indicating if resources created in this section need to be
      linked to resources in other accounts. if true, additional configuration
      for this section will be generated in a folder entitled "crosslink".

    imports:
      a list of key/value pairs where the key is the name of a local variable
      that will be accessible within the section and the value is a path to a
      YAML file containing shared config.
  EOF
}
