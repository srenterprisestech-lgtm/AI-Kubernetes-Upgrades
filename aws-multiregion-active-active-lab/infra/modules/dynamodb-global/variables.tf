variable "table_name" {
  description = "DynamoDB global table name."
  type        = string
}

variable "replica_region" {
  description = "Secondary region for global-table replication."
  type        = string
}
