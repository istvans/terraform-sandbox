provider "aws" {
    region = "eu-west-2"
}

/* how to get the ami id?
   - follow https://blog.gruntwork.io/locating-aws-ami-owner-id-and-image-name-for-packer-builds-7616fe46b49a
   - ubuntu product id from the aws page: 47489723-7305-4e22-8b22-b0d57054f216
   - sudo apt install awscli jq
   - make sure you have the right environment variables set: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
   - 14:48 $ aws ec2 describe-images --owners aws-marketplace --filters "Name=name,Values=*47489723-7305-4e22-8b22-b0d57054f216*" | jq -r '.Images[] | "\(.ImageId)\t\(.Name)\t\(.CreationDate)"'
     ami-03d132dde9b7bdcf3   ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220616-47489723-7305-4e22-8b22-b0d57054f216     2022-06-16T07:35:36.000Z
     ami-0a9f25ed07e7a4b0a   ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220528-47489723-7305-4e22-8b22-b0d57054f216     2022-05-28T08:50:33.000Z
     ami-06deb2d59d8f5b327   ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220712.1-47489723-7305-4e22-8b22-b0d57054f216   2022-07-12T21:19:09.000Z
     ami-08f747c4b84286acf   ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220604-47489723-7305-4e22-8b22-b0d57054f216     2022-06-04T07:35:14.000Z
     ami-06c52be8b83c2ce74   ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220506-47489723-7305-4e22-8b22-b0d57054f216     2022-05-11T13:26:02.000Z
     ami-0e3987cfcdb1dcee3   ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220708-47489723-7305-4e22-8b22-b0d57054f216     2022-07-08T07:46:20.000Z
     ami-061b70092a50e9522   ubuntu/images-testing/hvm-ssd/ubuntu-jammy-daily-amd64-server-20220419-47489723-7305-4e22-8b22-b0d57054f216     2022-04-20T12:50:05.000Z
     ami-0f474033296335790   ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220810-47489723-7305-4e22-8b22-b0d57054f216     2022-08-10T20:12:54.000Z
    let's pick the newest I guess?
*/
resource "aws_instance" "example" {
    ami                     = "ami-0f474033296335790"
    instance_type           = "t2.micro"
    vpc_security_group_ids  = [aws_security_group.instance.id]

    user_data = <<-EOF
        #!/usr/bin/env bash

        echo "Hello World!" > index.html
        nohup busybox httpd -f -p 8080 &
    EOF

    user_data_replace_on_change = true

    tags = {
        Name = "terraform-example"
    }
}

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
