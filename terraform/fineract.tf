
resource "aws_iam_role" "fineract_roles" {
  name = "fineract_${var.env}_roles"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "build.apprunner.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "fineract_rolespolicy" {
  role = aws_iam_role.fineract_roles.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "time_sleep" "waitrolecreate" {
  depends_on = [aws_iam_role.fineract_roles]
  create_duration = "60s"
}

resource "aws_apprunner_service" "fineract" {
  depends_on = [
    time_sleep.waitrolecreate,
    resource.aws_db_instance.fineract_postgres
  ]
  service_name = "fineract_${var.env}"

  instance_configuration {
    cpu = 2048
    memory = 4096
  }

  health_check_configuration {
    unhealthy_threshold = 20
  }

  source_configuration {
    authentication_configuration {
      access_role_arn = "${aws_iam_role.fineract_roles.arn}"
    }

    image_repository {
      image_configuration {
        port = "8000"
        runtime_environment_variables = {
          FINERACT_NODE_ID=1
          FINERACT_SERVER_PORT=8000
          FINERACT_SERVER_SSL_ENABLED=false
          # NOTE: env vars prefixed "FINERACT_HIKARI_*" are used to configure the database connection pool
          FINERACT_HIKARI_DRIVER_SOURCE_CLASS_NAME="org.postgresql.Driver"
          FINERACT_HIKARI_JDBC_URL="jdbc:postgresql://${aws_db_instance.fineract_postgres.endpoint}:5432/fineract_tenants"
          FINERACT_HIKARI_USERNAME="postgres"
          FINERACT_HIKARI_PASSWORD=data.aws_ssm_parameter.fineract_database_password.value
          # NOTE: env vars prefixed "FINERACT_DEFAULT_TENANTDB_*" are used to create the default tenant database
          FINERACT_DEFAULT_TENANTDB_HOSTNAME="${aws_db_instance.fineract_postgres.endpoint}"
          FINERACT_DEFAULT_TENANTDB_PORT=5432
          FINERACT_DEFAULT_TENANTDB_UID="postgres"
          FINERACT_DEFAULT_TENANTDB_PWD=data.aws_ssm_parameter.fineract_database_password.value
          FINERACT_DEFAULT_TENANTDB_CONN_PARAMS=""
          FINERACT_DEFAULT_TENANTDB_TIMEZONE="Asia/Kolkata"
          FINERACT_DEFAULT_TENANTDB_IDENTIFIER="default"
          FINERACT_DEFAULT_TENANTDB_NAME="fineract_default"
          FINERACT_DEFAULT_TENANTDB_DESCRIPTION="DefaultBurnTenant"
          JAVA_TOOL_OPTIONS="-Xmx1G"
        }
      }
      image_identifier      = "apache/fineract:latest"
      image_repository_type = "DOCKER_HUB"
    }
    auto_deployments_enabled = false
  }

  tags = {
    Name = "burnecore-apprunner-service"
    Environment = var.env
  }
}


# resource "aws_apprunner_service" "fineract_community_ui" {
#   service_name = "fineract_community_ui_${var.env}"

#   source_configuration {
#     authentication_configuration {
#       access_role_arn = "${aws_iam_role.fineract_roles.arn}"
#     }

#     image_repository {
#       image_configuration {
#         port = "80"
#       }
#       image_identifier      = "openmf/community-app:latest"
#       image_repository_type = "ECR_PUBLIC"
#     }
#     auto_deployments_enabled = false
#   }

#   tags = {
#     Name = "fineract-community-ui-apprunner-service"
#     Environment = var.env
#   }
# }