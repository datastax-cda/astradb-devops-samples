terraform {
 required_version = ">= 1.0.0"
 required_providers {
   astra = {
     source = "datastax/astra"
     version = ">=1.0.0"
   }
 }
}


provider "astra" {
  // This can also be set via ASTRA_API_TOKEN environment variable.
  token = var.token
}


#Create a database with a default keyspace using a resource
resource "astra_database" "bank_db" {
  name           = "bank_db"
  keyspace       = "bank_ks"
  cloud_provider = "gcp"
  regions        = ["us-east1"]
}


# Example role that grants policy permissions to specific keyspaces within a single Astra DB
resource "astra_role" "singledbrole" {
  role_name   = "singledbrole"
  description = "Role that applies to specific keyspaces for a single Astra DB"
  effect      = "allow"
  resources = [
    # apply role to the primary keyspace in the database
    "drn:astra:org:965c75d0-cec7-4230-80c8-6328341a0df3:db:${astra_database.bank_db.id}:keyspace:${astra_database.bank_db.keyspace}",

    ]
  policy = [
    # "org-db-view" is required to list databases
    "org-db-view",
    # the following are for CQl and table operations
    "db-cql", "db-table-alter", "db-table-create", "db-table-describe", "db-table-modify", "db-table-select",
    # the following are for Keysapce operations
    "db-keyspace-alter", "db-keyspace-describe", "db-keyspace-modify", "db-keyspace-authorize", "db-keyspace-drop", "db-keyspace-create", "db-keyspace-grant",
  ]
}
