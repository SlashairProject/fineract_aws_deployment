# Terraform for deploying fineract with postgresql to database.

## Getting started.

# 1. Create a database password and store it in aws ssm parameter store.
        - Terraform will use this password to create the database and pass it to fineract.
        - Parameter name in aws parameter store should be `fineract_database_password`.