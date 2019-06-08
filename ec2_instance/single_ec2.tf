# spin up single ec2 instance

# provider declaration
provider "aws" {
        region = "us-east-1"
}

# resource declaration
resource "aws_instance" "test1" {
    ami = "ami-0c6b1d09930fac512"
    instance_type = "t2.micro"
    tags = {
        Name = "singleec2instanceusingterraform"
    }
}
