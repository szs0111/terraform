# spin up single web server which returns "Hello, World"
# this code will prompt user for port number which will be used for webserver
# this code will also output public ip address of EC2 instance 

# provider declaration
provider "aws" {
        region = "us-east-1"
}

# variable declaration
variable "port_number" {
    description = "Please enter port no. that will be used for http requests"  
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
                nohup busybox httpd -f -p "${var.port_number}" &
                EOF
    tags = {
        Name = "webserver"
    }
}

# Security group
resource "aws_security_group" "webserver_securitygroup" {
    name = "webserver_securitygroup"
    ingress {
        from_port = "${var.port_number}"
        to_port = "${var.port_number}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# output public ip address of ec2 instance
output "public_ip" {
  value = "${aws_instance.webserver1.public_ip}"
}
