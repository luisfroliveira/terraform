provider "aws" {
  region  = "sa-east-1"
  access_key = "chave de acesso"
  secret_key = "chave secreta"
}

# RDS utilizando a engine do MySQL 8.0
resource "aws_db_instance" "mysql-terraform" {
  allocated_storage    = 20
  max_allocated_storage = 100
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "luis"
  password             = "luis1234"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  availability_zone = "sa-east-1c"

  tags = {
    Name        = "Meu MySQL"
    Environment = "DevOps"
  }

}
