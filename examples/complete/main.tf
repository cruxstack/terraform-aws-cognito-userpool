locals {
  name = "tf-example-complete-${random_string.example_random_suffix.result}"
  tags = { tf_module = "cruxstack/cognito-userpool/aws", tf_module_example = "complete" }
}

# ================================================================== example ===

module "congito_userpool" {
  source = "../../"

  domain = { enabled = true }

  context = module.example_label.context # not required
}

# ===================================================== supporting-resources ===

module "example_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name = local.name
  tags = local.tags
}

resource "random_string" "example_random_suffix" {
  length  = 6
  special = false
  upper   = false
}
