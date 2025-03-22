
resource "aws_iam_role" "fineract_apprunner_roles" {
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

resource "aws_iam_role_policy" "fineract_apprunner_policy" {
  name = "fineract-apprunner-policy"
  role = aws_iam_role.fineract_apprunner_roles.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "time_sleep" "waitrolecreate" {
  depends_on = [aws_iam_role.fineract_apprunner_roles]
  create_duration = "60s"
}

resource "aws_apprunner_service" "fineract" {
  depends_on = [
    time_sleep.waitrolecreate,
    resource.aws_db_instance.fineract_postgres,
    resource.aws_iam_role_policy.fineract_apprunner_policy,
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
    # authentication_configuration {
    #   access_role_arn = aws_iam_role.fineract_apprunner_roles.arn
    # }

    image_repository {
      image_configuration {
        port = "8000"
        runtime_environment_variables = {
          FINERACT_NODE_ID=1
          FINERACT_SERVER_PORT=8000
          FINERACT_SERVER_SSL_ENABLED=false
          # NOTE: env vars prefixed "FINERACT_HIKARI_*" are used to configure the database connection pool
          FINERACT_HIKARI_DRIVER_SOURCE_CLASS_NAME="org.postgresql.Driver"
          FINERACT_HIKARI_JDBC_URL="jdbc:postgresql://terraform-20250204182624425300000001.cx26maoectkb.eu-west-1.rds.amazonaws.com:5432/fineract_tenants"
          FINERACT_HIKARI_USERNAME="postgres"
          FINERACT_HIKARI_PASSWORD=data.aws_ssm_parameter.fineract_database_password.value
          # NOTE: env vars prefixed "FINERACT_DEFAULT_TENANTDB_*" are used to create the default tenant database
          FINERACT_DEFAULT_TENANTDB_HOSTNAME="terraform-20250204182624425300000001.cx26maoectkb.eu-west-1.rds.amazonaws.com"
          FINERACT_DEFAULT_TENANTDB_PORT=5432
          FINERACT_DEFAULT_TENANTDB_UID="postgres"
          FINERACT_DEFAULT_TENANTDB_PWD=data.aws_ssm_parameter.fineract_database_password.value
          FINERACT_DEFAULT_TENANTDB_CONN_PARAMS=""
          FINERACT_DEFAULT_TENANTDB_TIMEZONE="Asia/Kolkata"
          FINERACT_DEFAULT_TENANTDB_IDENTIFIER="default"
          FINERACT_DEFAULT_TENANTDB_NAME="fineract_default"
          FINERACT_DEFAULT_TENANTDB_DESCRIPTION="DefaultSyndikizaTenant"
          JAVA_TOOL_OPTIONS="-Xmx1G"
        }
      }
      image_identifier      = "public.ecr.aws/w0j8m6p8/fineract:latest"
      image_repository_type = "ECR_PUBLIC"
    }
    auto_deployments_enabled = false
  }

  tags = {
    Name = "syndikiza-apprunner-service"
    Environment = var.env
  }
}


resource "aws_apprunner_service" "fineract_community_ui" {
  service_name = "fineract_community_ui_${var.env}"

  source_configuration {
    # authentication_configuration {
    #   access_role_arn = "${aws_iam_role.fineract_roles.arn}"
    # }

    image_repository {
      image_configuration {
        port = "80"
      }
      image_identifier      = "public.ecr.aws/w0j8m6p8/fineract-ui:latest"
      image_repository_type = "ECR_PUBLIC"
    }
    auto_deployments_enabled = false
  }

  tags = {
    Name = "fineract-community-ui-apprunner-service"
    Environment = var.env
  }
}

resource "aws_apprunner_vpc_connector" "fineract_vpc_connector" {
  vpc_connector_name = "fineract-vpc-connector"
  subnets            = ["subnet-08b3fd4b347410294", "subnet-011ccc1fcf45ba05b", "subnet-0b3c4712b7c232d2d"]
  security_groups    = [aws_security_group.fineract_db_sg.id]
}