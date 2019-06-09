# spin up single web server which returns "Hello, World"

# provider declaration
provider "aws" {
        region = "us-east-1"
}

# resource declaration
# EC2 instance
resource "aws_instance" "webserver1" {
    ami = "ami-024a64a6685d05041"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.webserver_securitygroup.id}"]
    # User_data to run on bootup
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
    tags = {
        Name = "webserver"
    }
}

# Security group
resource "aws_security_group" "webserver_securitygroup" {
    name = "webserver_securitygroup"
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

