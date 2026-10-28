output "table_name" {
  description = "DynamoDB global table name."
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "DynamoDB global table ARN."
  value       = aws_dynamodb_table.this.arn
}
