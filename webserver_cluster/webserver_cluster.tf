# spin up web server cluster which returns "Hello, World"
# this code will prompt user for port number which will be used for webserver
# this code will also output public ip address of EC2 instances 
# introduction of lifecycle flag within terraform 
# introduction of data source declaration for AZ's
# nuance setting change to get public ip of multiple ec2 instances

# provider declaration
provider "aws" {
        region = "us-east-1"
}

# variable declaration
variable "port_number" {
    description = "Please enter port no. that will be used for http requests"  
}

# data source declaration
data "aws_availability_zones" "all" {}

# resource declaration
# launch configuration declaration for auto-scaling group
resource "aws_launch_configuration" "webserver" {
    image_id = "ami-024a64a6685d05041"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.webserver_securitygroup.id}"]
    name = "webserver launch configuration"
    # User_data to run on bootup
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p "${var.port_number}" &
                EOF
    # Lifecycle parameter
    lifecycle {
        create_before_destroy = true
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
    # Lifecycle parameter
    lifecycle {
        create_before_destroy = true
    }
}

# Auto-scaling group 
resource "aws_autoscaling_group" "webserver_autoscaling" {
    launch_configuration = "${aws_launch_configuration.webserver.id}"
    availability_zones = "${data.aws_availability_zones.all.names}"
    max_size = 6
    min_size = 2
    tag {
        key = "Name"
        value = "webserver_cluster_ec2instance"
        propagate_at_launch = true
    }
}

# output public ip address of ec2 instance
# output "public_ip_of_initial_instances" {
#    value = ["${aws_instance.webserver.*.public_ip}"]
# }
