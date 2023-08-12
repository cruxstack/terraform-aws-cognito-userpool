# Terraform Module: AWS Cognito Userpool

Terraform module to create AWS Cognito Userpools. This module is designed to
have sensiable defaults for a userpool and be easily extensible for more
advanced use cases.

## Usage

```hcl
module "cognito_userpool" {
  source  = "cruxstack/cognito-userpool/aws"
  version = "x.x.x"
}
```

## Inputs

In addition to the variables documented below, this module includes several
other optional variables (e.g., `name`, `tags`, etc.) provided by the
`cloudposse/label/null` module. Please refer to its [documentation](https://registry.terraform.io/modules/cloudposse/label/null/latest)
for more details on these variables.

| Name                             | Description                                                                                                                                                             |     Type     |         Default         | Required |
|----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------:|:-----------------------:|:--------:|
| `email_config`                   | Configuration email from the userpool.                                                                                                                                  |    object    |          `{}`           |    No    |
| `email_verification_message`     | A string representing the email verification message                                                                                                                    |    string    |          `""`           |    No    |
| `email_verification_subject`     | A string representing the email verification subject                                                                                                                    |    string    |          `""`           |    No    |
| `admin_create_user_config`       | The configuration for AdminCreateUser requests                                                                                                                          |    object    |          `{}`           |    No    |
| `alias_attributes`               | Attributes supported as an alias for this userpool. Possible values: phone_number, email, or preferred_username. Conflicts with `username_attributes`.                  | list(string) |          `[]`           |    No    |
| `username_attributes`            | Specifies whether email addresses or phone numbers can be specified as usernames when a user signs up. Conflicts with `alias_attributes`.                               | list(string) |         `null`          |    No    |
| `deletion_protection`            | When `true`, it prevents accidental deletion of your userpool. Before you can delete a userpool that you have protected against deletion, you must set this to `false`. |     bool     |         `true`          |    No    |
| `auto_verified_attributes`       | The attributes to be auto-verified. Possible values: `email`, `phone_number`.                                                                                           | list(string) |          `[]`           |    No    |
| `device_config`                  | The configuration for the userpool's device tracking.                                                                                                                   |    object    |          `{}`           |    No    |
| `lambda_config`                  | Configuration any AWS Lambda triggers associated with the userpool.                                                                                                     |    object    |          `{}`           |    No    |
| `mfa_config`                     | Set to enable multi-factor authentication. Must be one of the following values: `ON`, `OFF`, or `OPTIONAL`.                                                             |    string    |         `"OFF"`         |    No    |
| `password_policy`                | A container for information about the userpool password policy.                                                                                                         |    object    |          `{}`           |    No    |
| `recovery_mechanisms`            | List of account recovery options.                                                                                                                                       | list(string) |          `[]`           |    No    |
| `sms_config`                     | Configuration for SMS                                                                                                                                                   |    object    |          `{}`           |    No    |
| `sms_authentication_message`     | A string representing the SMS authentication message.                                                                                                                   |    string    | `"Your code is {####}"` |    No    |
| `sms_verification_message`       | A string representing the SMS verification message.                                                                                                                     |    string    | `"Your code is {####}"` |    No    |
| `software_token_mfa_config`      | Configuration for software token multi-factor authentication.                                                                                                           |    object    |          `{}`           |    No    |
| `user_attribute_schemas`         | Map of all user attribute schemas. The key is the attribute name.                                                                                                       | map(object)  |          `{}`           |    No    |
| `user_attribute_update_settings` | Configuration block for user attribute update settings.                                                                                                                 |    object    |          `{}`           |    No    |
| `username_config`                | Configuration for sername. Setting `case_sensitive` specifies whether username case sensitivity will be applied for all users in the userpool through Cognito APIs.     |    object    |          `{}`           |    No    |
| `userpool_add_ons`               | Configuration block for userpool add-ons to enable userpool advanced security mode features                                                                             |    object    |          `{}`           |    No    |
| `verification_message_template`  | Configuration for verification message templates.                                                                                                                       |    object    |          `{}`           |    No    |

## Outputs

| Name                 | Description                          |
|----------------------|--------------------------------------|
| `id`                 | ID of the userpool.                  |
| `arn`                | ARN of the userpool.                 |
| `name`               | Name of the userpool.                |
| `endpoint`           | Dndpoint name of the userpool.       |
| `creation_date`      | Date the userpool was created.       |
| `last_modified_date` | Date the userpool was last modified. |

## Contributing

We welcome contributions to this project. For information on setting up a
development environment and how to make a contribution, see [CONTRIBUTING](./CONTRIBUTING.md)
documentation.
