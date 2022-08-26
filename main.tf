variable "server_port" {
    type        = number
    description = "The port the server will use for HTTP requests"
    default     = 8080
}

provider "aws" {
    region = "eu-west-2"
}

resource "aws_instance" "example" {
    ami                     = "ami-0f474033296335790"
    instance_type           = "t2.micro"
    vpc_security_group_ids  = [aws_security_group.instance.id]

    user_data = <<-EOF
        #!/usr/bin/env bash

        echo "Hello World!" > index.html
        nohup busybox httpd -f -p ${var.server_port} &
    EOF

    user_data_replace_on_change = true

    tags = {
        Name = "terraform-example"
    }
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public_ip" {
    value       = aws_instance.example.public_ip
    description = "The public IP address of the web server"
}
