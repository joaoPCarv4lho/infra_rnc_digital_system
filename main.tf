provider "aws" {
  region = "us-east-1"

}

resource "aws_security_group" "securitygroup" {
    name = "securitygroup"
    description = "Permite acesso as portas do docker compose e acesso a internet"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acesso SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acesso HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acesso HTTPS"
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Porta do PostgreSQL"
  }

  ingress {
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Porta do pgadmin"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Porta do Backend"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Porta do Frontend"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite acesso externo"
  }
}

resource "aws_key_pair" "keypair" {
    key_name = "terraform-keypair"
    public_key = file("~/.ssh/id_ed25519.pub")

}


resource "aws_instance" "servidor" {
  ami = "ami-0c398cb65a93047f2" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type - us-east-1
  instance_type = "t3.micro"
  user_data = file("user_data.sh")
  key_name = aws_key_pair.keypair.key_name
  vpc_security_group_ids = [aws_security_group.securitygroup.id]


  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")   
    host        = self.public_ip
  }

  provisioner "remote-exec" {
  inline = [
    "sudo mkdir -p /opt/app",
    "sudo chown ubuntu:ubuntu /opt/app"
  ]
}

  provisioner "file" {
    source      = "backend.env"
    destination = "/opt/app/backend.env"
  }

  provisioner "file" {
    source      = "frontend.env"
    destination = "/opt/app/frontend.env"
  }
  
  provisioner "file" {
    source      = "db.env"
    destination = "/opt/app/db.env"
  }

  tags = {
    Name = "compose-app-server"
  }
}