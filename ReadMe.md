# Terraform for deploying fineract with postgresql to database.

## Getting started.

# Aws cli login

        aws configure sso
        aws sts get-caller-identity --profile syndikiza_admin

        Set the profile the default
                export AWS_PROFILE=syndikiza_admin

### Publishing fineract image to ecr.
Create repository if it does not exist:

        aws ecr-public create-repository --repository-name fineract --region us-east-1 --profile syndikiza_admin

docker login 
        aws ecr-public get-login-password --region us-east-1 --profile syndikiza_admin | docker login --username AWS --password-stdin public.ecr.aws

Pull fineract image to use:
        docker pull apache/fineract:3aa011b32

Tag docker image to use:
        
        docker tag apache/fineract:3aa011b32 public.ecr.aws/w0j8m6p8/fineract:latest

Push docker image to ecr:

        docker push public.ecr.aws/w0j8m6p8/fineract:latest

### Publishing fineract web app image to ecr.
openmf/web-app
Create repository if it does not exist:

        aws ecr-public create-repository --repository-name fineract-webapp --region us-east-1 --profile syndikiza_admin

# 2. Create a database password and store it in aws ssm parameter store.
        - Terraform will use this password to create the database and pass it to fineract.
        - Parameter name in aws parameter store should be `fineract_database_password`.
        - Fineract using two databases main and tenant.
        Make sure to create the second database as terraform will only create the first one.
# 3. Deploying the infrastructure.

terraform apply