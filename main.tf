provider "aws" {
  region = "us-east-2"
}

resource "aws_key_pair" "default" {
  key_name = "hw_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9D3RAApIbFi7P830RoJaJ+IJk4hfYsv68f7Ysm6Axzer85NL6Q4pkkiu4PRVx6CyvOJNAa2gUrFl6JKCzRUCPEf6E9i67ejqxeXTVKlHRzLRa1P9kbd3Ojahitj2HGg8T01g30T7apq+e5a7ozsaivMzf3Jl3TYUGX5z4B+RMEdYzG2y5MCWCqy1qNCqEl4c+e9+eyw4ox2LJVlvaAZ7E/AbN6ubhtTz7oXOfavH0HCiUD5RfDZX4h5bf61zieK03wD08YvlAghlVUkCv++GKIoFRuvN9MESnO5oyqMvCdySHDmlA3jiFPL2iRqeLYKF1oGIQJruZAZJV7GbZsNf29K21KcPWPwsqUBEuImub75DAXN8M4wMBEvUB+ushBCHFf3zYOxtHaRZG04Wfi18YGZn7gkqaHbnytu3eETSdjgLNOIWEnGXdA1vGR4BQ5wLhd6puxtWlVN9eZ6Ls9kseDMUdfZGfUSKJg+zSFF7nQPu+bIv7oHKc8xSFHTlrTJM= zfolwick@Zacharys-MBP"
}

#creating security group, allow ssh and http

resource "aws_security_group" "hello-terra-ssh-http" {
  name = "hello-terra-http-ssh"
  description = "allowing ssh and http and ping traffic"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "hello-webserver" {
  ami           = "ami-01aab85a5e4a5a0fe"
  instance_type = "t2.micro"
  availability_zone = "us-east-2b"
  security_groups = [aws_security_group.hello-terra-ssh-http.name]
  key_name = aws_key_pair.default.key_name
  tags = {
    Name = "terry_form"
  }
  user_data = <<-EOF
    #! /bin/bash
    sudo yum install httpd -y
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo wget https://gist.githubusercontent.com/lillylangtree/b55828fa05ed3470d352/raw/3a7183fb56493ca42b5ddeeb73895f5a8cb1d6d3/index.html --directory-prefix=/var/www/html/
    EOF
}

# prints out the public ip address. It appears "terraform apply" must be run twice for this to take affect.
output "public_ip" {
  value = aws_instance.hello-webserver.public_ip
}
