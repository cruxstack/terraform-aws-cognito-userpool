# ================================================================= userpool ===

variable "email_config" {
  type = object({
    configuration_set      = optional(string)
    email_sending_account  = optional(string, "COGNITO_DEFAULT")
    from_email_address     = optional(string)
    reply_to_email_address = optional(string, "")
    source_arn             = optional(string, "")
    verification_message   = optional(string, "")
    verification_subject   = optional(string, "")
  })
  description = "Configuration email from the userpool."
  default     = {}
}

variable "email_verification_message" {
  type        = string
  description = "A string representing the email verification message"
  default     = ""
}

variable "email_verification_subject" {
  type        = string
  description = "A string representing the email verification subject"
  default     = ""
}

variable "admin_create_user_config" {
  type = object({
    allow_admin_create_user_only = optional(bool, true)
    email_message                = optional(string, "{username}, your verification code is `{####}`")
    email_subject                = optional(string, "Your verification code")
    sms_message                  = optional(string, "Your username is {username} and temporary password is `{####}`")
  })
  description = "The configuration for AdminCreateUser requests"
  default     = {}
}

variable "alias_attributes" {
  type        = list(string)
  description = <<-EOF
    Attributes supported as an alias for this userpool. Possible values: phone_number, email, or preferred_username.
    Conflicts with `username_attributes`.
  EOF
  default     = []

  validation {
    condition     = alltrue([for x in var.alias_attributes : contains(["phone_number", "email", "preferred_username"], lower(x))])
    error_message = "The `alias_attributes` must be one or more of `phone_number`, `email`, or `preferred_username`."
  }
}

variable "username_attributes" {
  type        = list(string)
  description = <<-EOF
    Specifies whether email addresses or phone numbers can be specified as usernames when a user signs up. Conflicts
    with `alias_attributes`.
  EOF
  default     = null
}

variable "deletion_protection" {
  type        = bool
  description = <<-EOF
    When `true`, it prevents accidental deletion of your userpool. Before you can delete a userpool that you have
    protected against deletion, you must set this to `false`.
  EOF
  default     = true
}

variable "auto_verified_attributes" {
  type        = list(string)
  description = "The attributes to be auto-verified. Possible values: `email`, `phone_number`."
  default     = []
}

variable "device_config" {
  type = object({
    challenge_required_on_new_device      = optional(bool, false)
    device_only_remembered_on_user_prompt = optional(bool, false)
  })
  description = "The configuration for the userpool's device tracking."
  default     = {}
}

variable "lambda_config" {
  type = object({
    create_auth_challenge          = optional(string)
    custom_message                 = optional(string)
    define_auth_challenge          = optional(string)
    post_authentication            = optional(string)
    post_confirmation              = optional(string)
    pre_authentication             = optional(string)
    pre_sign_up                    = optional(string)
    pre_token_generation           = optional(string)
    user_migration                 = optional(string)
    verify_auth_challenge_response = optional(string)
    kms_key_id                     = optional(string)
    custom_email_sender = optional(object({
      lambda_arn     = optional(string)
      lambda_version = optional(string, "V1_0")
    }), {})
    custom_sms_sender = optional(object({
      lambda_arn     = optional(string)
      lambda_version = optional(string, "V1_0")
    }), {})
  })
  description = "Configuration any AWS Lambda triggers associated with the userpool."
  default     = {}

  validation {
    condition     = !(coalesce(var.lambda_config.kms_key_id, "__UNSET__") == "__UNSET__" && (coalesce(var.lambda_config.custom_sms_sender.lambda_arn, "__UNSET__") != "__UNSET__" || coalesce(var.lambda_config.custom_sms_sender.lambda_arn, "__UNSET__") != "__UNSET__"))
    error_message = "The `kms_key_id` must be set when using configuring either `custom_sms_sender` or `custom_email_sender` triggers."
  }
}

variable "mfa_config" {
  type        = string
  description = <<-EOF
    Set to enable multi-factor authentication. Must be one of the following values: `ON`, `OFF`, or `OPTIONAL`.
  EOF
  default     = "OFF"

  validation {
    condition     = contains(["ON", "OFF", "OPTIONAL"], upper(var.mfa_config))
    error_message = "The `mfa_config` must be one of `ON`, `OFF`, or `OPTIONAL`."
  }
}

variable "password_policy" {
  type = object({
    minimum_length                   = optional(number, 8),
    require_lowercase                = optional(bool, true),
    require_numbers                  = optional(bool, true),
    require_symbols                  = optional(bool, true),
    require_uppercase                = optional(bool, true),
    temporary_password_validity_days = optional(number, 7)
  })
  description = "A container for information about the userpool password policy."
  default     = {}
}

variable "recovery_mechanisms" {
  type        = list(string)
  description = "List of account reecovery options."
  default     = []

  validation {
    condition     = length(var.recovery_mechanisms) == 0 || alltrue([for x in var.recovery_mechanisms : contains(["verified_email", "verified_phone_number", "admin_only"], lower(x))])
    error_message = "The `recovery_mechanisms` must be one of `verified_email`, `verified_phone_number`, or `admin_only`."
  }
}

variable "sms_config" {
  type = object({
    enabled        = optional(bool, false)
    external_id    = optional(string, "")
    sns_caller_arn = optional(string, "")
  })
  description = "Configuration for SMS"
  default     = {}
}

variable "sms_authentication_message" {
  type        = string
  description = "A string representing the SMS authentication message."
  default     = "Your code is {####}"
}

variable "sms_verification_message" {
  type        = string
  description = "A string representing the SMS verification message."
  default     = "Your code is {####}"
}

variable "software_token_mfa_config" {
  type = object({
    enabled = optional(bool, false)
  })
  description = "Configuration for software token multi-factor authentication."
  default     = {}
}

variable "user_attribute_schemas" {
  type = map(object({
    required                 = optional(bool, false)
    attribute_data_type      = string
    developer_only_attribute = optional(bool, false)
    mutable                  = optional(bool, false)
    number_attribute_constraints = optional(object({
      max_value = optional(string)
      min_value = optional(string)
    }))
    string_attribute_constraints = optional(object({
      max_length = optional(string)
      min_length = optional(string)
    }))
  }))
  description = "Map of all user attribute schemas. The key is the attribute name."
  default     = {}
}

variable "user_attribute_update_settings" {
  type = object({
    attributes_require_verification_before_update = optional(list(string), [])
  })
  description = "Configuration block for user attribute update settings."
  default     = {}

  validation {
    condition     = alltrue([for x in var.user_attribute_update_settings.attributes_require_verification_before_update : contains(["email", "phone_number"], lower(x))])
    error_message = "The `attributes_require_verification_before_update` must be a list of `email` and `phone_number`"
  }
}

variable "username_config" {
  type = object({
    case_sensitive = optional(bool, true)
  })
  description = <<-EOF
    Configuration for sername. Setting `case_sensitive` specifies whether username case sensitivity will be applied for
    all users in the userpool through Cognito APIs.
  EOF
  default     = {}
}

variable "userpool_add_ons" {
  type = object({
    advanced_security_mode = optional(string, "off")
  })
  description = "Configuration block for userpool add-ons to enable userpool advanced security mode features"
  default     = {}
}

variable "verification_message_template" {
  type = object({
    default_email_option  = optional(string, "CONFIRM_WITH_CODE")
    email_message_by_link = optional(string, "{##Click Here##}")
    email_subject_by_link = optional(string, "Your verification code")
  })
  description = "Configuration for verification message templates."
  default     = {}
}
