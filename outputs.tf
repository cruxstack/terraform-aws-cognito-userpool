output "id" {
  description = "ID of the userpool."
  value       = local.enabled ? aws_cognito_user_pool.this[0].id : null
}

output "arn" {
  description = "ARN of the userpool."
  value       = local.enabled ? aws_cognito_user_pool.this[0].arn : null
}

output "name" {
  description = "Name of the userpool."
  value       = local.enabled ? aws_cognito_user_pool.this[0].name : null
}

output "endpoint" {
  description = "Endpoint name of the userpool."
  value       = local.enabled ? aws_cognito_user_pool.this[0].endpoint : null
}

output "creation_date" {
  description = "Date the userpool was created."
  value       = local.enabled ? aws_cognito_user_pool.this[0].creation_date : null
}

output "last_modified_date" {
  description = "Date the userpool was last modified."
  value       = local.enabled ? aws_cognito_user_pool.this[0].last_modified_date : null
}

output "resource_servers" {
  description = "Map of resource servers with their identifiers and scope identifiers."
  value = {
    for k, v in aws_cognito_resource_server.this : k => {
      identifier        = v.identifier
      scope_identifiers = v.scope_identifiers
    }
  }
}
