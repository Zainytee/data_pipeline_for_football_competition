resource "aws_db_subnet_group" "rds_sg" {
  name       = "data-engineering"
  subnet_ids = [aws_subnet.vpc_subnet_a.id, aws_subnet.vpc_subnet_b.id]

  tags = {
    Name = "My DB subnet group"
  }
}


resource "aws_db_parameter_group" "rds_pg" {
  name   = "data-engineering"
  family = "postgres16"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}


resource "random_password" "database_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_numeric      = 1
}

data "aws_ssm_parameter" "rds_username" {
  name = "/production/database/username/master_"
}


resource "aws_ssm_parameter" "rds_password_secret" {
  name        = "/production/database/password/master"
  description = "The rds master password"
  type        = "String"
  value       = random_password.database_password.result
}



resource "aws_db_instance" "rds_instance" {
  identifier                  = "data-engineering"
  instance_class              = "db.t3.micro"
  allocated_storage           = 10
  engine                      = "postgres"
  engine_version              = "16"
  db_name                     = "rds_db"
  username                    = data.aws_ssm_parameter.rds_username.value
  password                    = random_password.database_password.result
  db_subnet_group_name        = aws_db_subnet_group.rds_sg.name
  vpc_security_group_ids      = [aws_security_group.vpc_secure.id]
  parameter_group_name        = aws_db_parameter_group.rds_pg.name
  publicly_accessible         = true
  skip_final_snapshot         = true
  allow_major_version_upgrade = true
}



