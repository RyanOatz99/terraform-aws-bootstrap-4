provider "aws" {
  profile = "${profile}"
  region  = "${region}"
  %{~ if alias != null ~}
  alias   = "${alias}"
  %{~ endif ~}
}