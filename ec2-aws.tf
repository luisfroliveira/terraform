provider "aws" {
  region  = "sa-east-1"
  access_key = "AKIA2ZIEWSSNKYWV75XJ"
  secret_key = "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"
}

# Criando a VPC
resource "aws_vpc" "vpc-ubuntu" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "estudo-vpc"
  }
}

# Criando a Subnet
resource "aws_subnet" "subnet-ubuntu" {
  vpc_id     = aws_vpc.vpc-ubuntu.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "sa-east-1a"

  tags = {
    Name = "estudo-subnet"
  }
}

# Criando Gateway de Internet
resource "aws_internet_gateway" "gateway-ubuntu" {
  vpc_id = aws_vpc.vpc-ubuntu.id

}

# Criando tabela de roteamento de rede
resource "aws_route_table" "route-ubuntu" {
  vpc_id = aws_vpc.vpc-ubuntu.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway-ubuntu.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gateway-ubuntu.id
  }

  tags = {
    Name = "estudo-route"
  }
}

# Associando a Subnet a route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-ubuntu.id
  route_table_id = aws_route_table.route-ubuntu.id
}

# Criando um grupo de segurança para as portas 22 e 80
resource "aws_security_group" "allow_ubuntu" {
  name        = "allow_web"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.vpc-ubuntu.id

 ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
   ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
 }

  tags = {
    Name = "allow_web"
  }
}

# Interface de Rede
resource "aws_network_interface" "interface-ubuntu" {
  subnet_id       = aws_subnet.subnet-ubuntu.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_ubuntu.id]
}

# IP fixo
resource "aws_eip" "ip-ubuntu" {
  vpc                       = true
  network_interface         = aws_network_interface.interface-ubuntu.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gateway-ubuntu]
}

# Criando servidor ubuntu com Apache Server
resource "aws_instance" "servidor_web" {
  ami           = "ami-0b22b708611ed2690"
  instance_type = "t2.micro"
  availability_zone = "sa-east-1a"
  key_name = "ec2-terraform"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.interface-ubuntu.id
  }

  user_data = <<-EOF
                  #!/bin/bash
                  sudo apt update -y
                  sudo apt install apache2 -y
                  sudo systemctl start apache2
                  sudo bash -c 'echo Meu primeiro Web Server com Terraform > /var/www/html/index.html'
                  sudo apt install net-tools
                  EOF

    tags = {
      Name = "estudo-ec2"
    }
}
