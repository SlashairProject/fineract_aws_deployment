// ...existing code...

resource "aws_db_instance" "fineract_postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = "db.t3.small"
  db_name              = "fineractdb"
  username             = "postgres"
  password             = data.aws_ssm_parameter.fineract_database_password.value
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.fineract_db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.fineract_db_subnet_group.name
}

resource "aws_security_group" "fineract_db_sg" {
  name        = "fineract_db_sg"
  description = "Security group for Fineract PostgreSQL RDS instance"
  vpc_id      = "vpc-0e9165aada2b154b0"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "fineract_db_subnet_group" {
  name       = "fineract_db_subnet_group"
  subnet_ids = ["subnet-08b3fd4b347410294", "subnet-011ccc1fcf45ba05b", "subnet-0b3c4712b7c232d2d"]
  description = "Subnet group for Fineract PostgreSQL RDS instance"
}