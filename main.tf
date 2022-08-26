variable "server_port" {
    type        = number
    description = "The port the server will use for HTTP requests"
    default     = 8080
}

provider "aws" {
    region = "eu-west-2"
}

data "aws_vpc" "get_default" {
    default = true
}

data "aws_subnets" "get_default" {
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.get_default.id]
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

resource "aws_launch_configuration" "example" {
    image_id                = "ami-0f474033296335790"
    instance_type           = "t2.micro"
    security_groups         = [aws_security_group.instance.id]

    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World" > index.html
        nohup busybox httpd -f -p ${var.server_port} &
    EOF

    # Required when using a launch configuration with an auto scaling group.
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier  = data.aws_subnets.get_default.ids

    min_size = 2
    max_size = 10

    tag {
        key                 = "Name"
        value               = "terraform-asg-example"
        propagate_at_launch = true
    }
}
