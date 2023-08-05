output "id" {
  description = "ID of the userpool."
  value       = module.congito_userpool.id
}

output "arn" {
  description = "ARN of the userpool."
  value       = module.congito_userpool.arn
}

output "name" {
  description = "Name of the userpool."
  value       = module.congito_userpool.name
}

output "endpoint" {
  description = "Endpoint name of the userpool."
  value       = module.congito_userpool.endpoint
}

output "creation_date" {
  description = "Date the userpool was created."
  value       = module.congito_userpool.creation_date
}

output "last_modified_date" {
  description = "Date the userpool was last modified."
  value       = module.congito_userpool.last_modified_date
}
