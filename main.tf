locals {
  enabled = coalesce(var.enabled, module.this.enabled, true)
  name    = coalesce(var.name, module.this.name, "idp-${random_string.cognito_userpool_random_suffix.result}")
}

# -------------------------------------------------------------------- label ---

module "cognito_userpool_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled = local.enabled
  name    = local.name
  context = module.this.context
}

# only appliable if name variable was not set
resource "random_string" "cognito_userpool_random_suffix" {
  length  = 6
  special = false
  upper   = false
}

# ================================================================= userpool ===

resource "aws_cognito_user_pool" "this" {
  count = local.enabled ? 1 : 0

  name                       = module.cognito_userpool_label.id
  alias_attributes           = var.alias_attributes
  auto_verified_attributes   = var.auto_verified_attributes
  email_verification_subject = coalesce(var.email_verification_subject, var.admin_create_user_config.email_subject)
  email_verification_message = coalesce(var.email_verification_message, var.admin_create_user_config.email_message)
  mfa_configuration          = upper(var.mfa_config)
  sms_authentication_message = var.sms_authentication_message
  sms_verification_message   = var.sms_verification_message
  username_attributes        = var.username_attributes
  deletion_protection        = var.deletion_protection ? "ACTIVE" : "INACTIVE"

  admin_create_user_config {
    allow_admin_create_user_only = var.admin_create_user_config.allow_admin_create_user_only
    invite_message_template {
      email_message = var.admin_create_user_config.email_message
      email_subject = var.admin_create_user_config.email_subject
      sms_message   = var.admin_create_user_config.sms_message
    }
  }

  device_configuration {
    challenge_required_on_new_device      = var.device_config.challenge_required_on_new_device
    device_only_remembered_on_user_prompt = var.device_config.device_only_remembered_on_user_prompt
  }

  email_configuration {
    configuration_set      = var.email_config.configuration_set
    reply_to_email_address = var.email_config.reply_to_email_address
    source_arn             = var.email_config.source_arn
    email_sending_account  = var.email_config.email_sending_account
    from_email_address     = var.email_config.from_email_address
  }

  lambda_config {
    create_auth_challenge          = var.lambda_config.create_auth_challenge
    custom_message                 = var.lambda_config.custom_message
    define_auth_challenge          = var.lambda_config.define_auth_challenge
    post_authentication            = var.lambda_config.post_authentication
    post_confirmation              = var.lambda_config.post_confirmation
    pre_authentication             = var.lambda_config.pre_authentication
    pre_sign_up                    = var.lambda_config.pre_sign_up
    pre_token_generation           = var.lambda_config.pre_token_generation
    user_migration                 = var.lambda_config.user_migration
    verify_auth_challenge_response = var.lambda_config.verify_auth_challenge_response
    kms_key_id                     = var.lambda_config.kms_key_id

    dynamic "custom_email_sender" {
      for_each = coalesce(var.lambda_config.custom_email_sender.lambda_arn, "__UNSET__") != "__UNSET__" ? [true] : []
      content {
        lambda_arn     = var.lambda_config.custom_email_sender.lambda_arn
        lambda_version = var.lambda_config.custom_email_sender.lambda_version
      }
    }

    dynamic "custom_sms_sender" {
      for_each = coalesce(var.lambda_config.custom_sms_sender.lambda_arn, "__UNSET__") != "__UNSET__" ? [true] : []
      content {
        lambda_arn     = var.lambda_config.custom_sms_sender.lambda_arn
        lambda_version = var.lambda_config.custom_sms_sender.lambda_version
      }
    }
  }

  password_policy {
    minimum_length                   = var.password_policy.minimum_length
    require_lowercase                = var.password_policy.require_lowercase
    require_numbers                  = var.password_policy.require_numbers
    require_symbols                  = var.password_policy.require_symbols
    require_uppercase                = var.password_policy.require_uppercase
    temporary_password_validity_days = var.password_policy.temporary_password_validity_days
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = try(coalescelist(var.user_attribute_update_settings.attributes_require_verification_before_update, var.auto_verified_attributes, []), [])
  }

  username_configuration {
    case_sensitive = var.username_config.case_sensitive
  }

  verification_message_template {
    default_email_option  = var.verification_message_template.default_email_option
    email_message_by_link = var.verification_message_template.email_message_by_link
    email_subject_by_link = var.verification_message_template.email_subject_by_link
  }

  dynamic "account_recovery_setting" {
    for_each = length(var.recovery_mechanisms) == 0 ? [] : [1]
    content {
      dynamic "recovery_mechanism" {
        for_each = var.recovery_mechanisms
        content {
          name     = recovery_mechanism.value
          priority = index(var.recovery_mechanisms, recovery_mechanism.value) + 1
        }
      }
    }
  }

  dynamic "schema" {
    for_each = var.user_attribute_schemas

    content {
      name                     = schema.key
      attribute_data_type      = schema.value
      developer_only_attribute = schema.value
      mutable                  = schema.value
      required                 = schema.value
    }
  }

  dynamic "sms_configuration" {
    for_each = var.sms_config.enabled ? [true] : []
    content {
      external_id    = var.sms_config.external_id
      sns_caller_arn = coalesce(var.sms_config.sns_caller_arn, aws_iam_role.sms.arn)
    }
  }

  dynamic "software_token_mfa_configuration" {
    for_each = upper(var.mfa_config) != "OFF" ? [true] : []
    content {
      enabled = var.software_token_mfa_config.enabled
    }
  }

  dynamic "user_pool_add_ons" {
    for_each = upper(var.userpool_add_ons.advanced_security_mode) != "OFF" ? [true] : []
    content {
      advanced_security_mode = upper(var.userpool_add_ons.advanced_security_mode)
    }
  }

  tags = module.cognito_userpool_label.tags
}

# ---------------------------------------------------------------------- iam ---

module "cognito_userpool_sms_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["sms"]
  context    = module.cognito_userpool_label.context
}

resource "random_uuid" "sms_role_external_id" {}

data "aws_iam_policy_document" "sms" {
  statement {
    effect = "Allow"

    actions = [
      "sns:publish",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "sms" {
  count = local.enabled ? 1 : 0

  name        = module.cognito_userpool_sms_label.id
  description = ""
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { "Service" : "cognito-idp.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
      condition = { "StringEquals" = { "sts:ExternalId" = random_uuid.sms_role_external_id.result } }
    }]
  })

  inline_policy {
    name   = "access"
    policy = data.aws_iam_policy_document.sms.json
  }

  tags = module.cognito_userpool_sms_label.tags
}
