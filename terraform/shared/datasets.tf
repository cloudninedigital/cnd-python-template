### uncomment this file (CTRL+A CTRL+/) and change example values to your own situation. 
### If you wish to use the dev / stg dataset logic, make sure you also update the locals.replace_tables field with every new dataset you add / alter. 

# module "dataset_dasbright" {
#     source = "../modules/bq_dataset"
#     dataset_id = "dasbright"
#     description = "dataset for the data out of dasbright API"
#     region = "EU"
#     friendly_name = "Dasbright API dataset"
#     tables = {
#         client_updates = {
#             table_id = "client_updates"
#             partition_table = true
#             partition_type = "DAY"
#             partition_field = "date"
#             schema = [{
#                 name = "date"
#                 type = "date"
#                 description = "date of occured action"
#             },
#             {
#                 name = "timestamp"
#                 type = "timestamp"
#                 description = "timestamp of occured action"
#             },
#             {
#                 name = "segment"
#                 type = "string"
#                 description = "segment in which customer is"
#             },
#             {
#                 name = "clientID"
#                 type = "string"
#                 description = "ID of client"
#             },
#             {
#                 name = "productType"
#                 type = "string"
#                 description = "type of product"
#             },
#             {
#                 name = "productId"
#                 type = "integer"
#                 description = "ID of product"
#             },
#             {
#                 name = "depositStatus"
#                 type = "string"
#                 description = "status of deposit"
#             },
#             {
#                 name = "membershipStatus"
#                 type = "string"
#                 description = "status of client membership"
#             },
#              {
#                 name = "typeOfIndividual"
#                 type = "string"
#                 description = "Type of client"
#             },
#             {
#                 name = "employerId"
#                 type = "integer"
#                 description = "Id of client employer"
#             },
#             {
#                 name = "definition"
#                 type = "string"
#                 description = "defition of occured event"
#             },
#             {
#                 name = "loadts"
#                 type = "timestamp"
#                 description = "timestamp of data load"
#             },]
#         }
#         }
# }


# module "dataset_staging_dasbright" {
#     source = "../modules/bq_dataset"
#     dataset_id = "staging_dasbright"
#     description = "dataset for the staging of data out of dasbright API"
#     region = "EU"
#     friendly_name = "Dasbright API staging dataset"
#     tables = {
#         client_updates = {
#             table_id = "client_updates"
#             schema = [{
#                 name = "date"
#                 type = "string"
#                 description = "timestamp of occured action (even though named date)"
#             },
#             {
#                 name = "segment"
#                 type = "string"
#                 description = "segment in which customer is"
#             },
#             {
#                 name = "clientID"
#                 type = "string"
#                 description = "ID of client"
#             },
#             {
#                 name = "productType"
#                 type = "string"
#                 description = "type of product"
#             },
#             {
#                 name = "productId"
#                 type = "integer"
#                 description = "ID of product"
#             },
#             {
#                 name = "depositStatus"
#                 type = "string"
#                 description = "status of deposit"
#             },
#             {
#                 name = "membershipStatus"
#                 type = "string"
#                 description = "status of client membership"
#             },
#              {
#                 name = "typeOfIndividual"
#                 type = "string"
#                 description = "Type of client"
#             },
#             {
#                 name = "employerId"
#                 type = "integer"
#                 description = "Id of client employer"
#             },
#             {
#                 name = "definition"
#                 type = "string"
#                 description = "defition of occured event"
#             },
#             {
#                 name = "loadts"
#                 type = "timestamp"
#                 description = "timestamp of data load"
#             },]
#         }
#         }
# }

# ### This part makes sure dev and test tables are created from the managed datasets above! 
# ### To add upon this, simply add a new dataset module in the merge statement like `module.dataset_<>.tables`. 

# locals {
#   replace_tables = { 
#     for table_name, table_definition in 
#         merge(
#         module.dataset_staging_dasbright.table_definitions,
#         module.dataset_dasbright.table_definitions)
#          : table_name => {
#         table_id = "${table_definition.dataset}_${table_definition.table.table_id}"
#         schema  = table_definition.table.schema
#       }
#     }
# }

# module "dev" {
#     source = "../modules/bq_dataset"
#     dataset_id = "dev"
#     description = "dataset for all dev table replacements"
#     region = "EU"
#     friendly_name = "dev dataset"
#     tables = local.replace_tables
# }

# module "stg" {
#     source = "../modules/bq_dataset"
#     dataset_id = "stg"
#     description = "dataset for all test table replacements"
#     region = "EU"
#     friendly_name = "stg dataset"
#     tables = local.replace_tables
# }