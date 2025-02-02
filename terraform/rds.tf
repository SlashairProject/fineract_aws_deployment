// ...existing code...

resource "aws_db_instance" "fineract_postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13.7"
  instance_class       = "db.t3.micro"
  name                 = "fineractdb"
  username             = "postgres"
  password             = data.aws_ssm_parameter.fineract_database_password.value
  parameter_group_name = "default.postgres13"
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.fineract_db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.fineract_db_subnet_group.name
}

resource "aws_security_group" "fineract_db_sg" {
  name        = "fineract_db_sg"
  description = "Security group for Fineract PostgreSQL RDS instance"
  vpc_id      = "vpc-0905dcf8f399f8caf"

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
  subnet_ids = ["subnet-04eacb9d626ecc886", "subnet-0f8f739e76415a2cf", "subnet-05dd773dc359cf136"]
  description = "Subnet group for Fineract PostgreSQL RDS instance"
}