provider "aws" {
    region = "eu-central-1"
}

variable "ansible-ip" {
    default = "20.111.8.195/32"
}
variable "jenkins-ip" {
    default = "139.162.156.240/32"
}
variable "vpc-cidr-block" {
    default = "10.0.0.0/16"
}
variable "subnet-cidr-block" {
    default = "10.0.10.0/24"
}
variable "avail_zone" {
    default = "eu-central-1b"
}
variable "env_prefix" {
    default = "dev"
}
variable "myip" {
    default = "41.140.197.249/32"
}
variable "pub_key_location" {
    default = "/var/jenkins_home/.ssh/id_rsa.pub"
}
variable "private_key_location" {
    default = "/var/jenkins_home/.ssh/id_rsa"
}



resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc-cidr-block
    enable_dns_hostnames = true
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet-cidr-block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}



resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.myapp-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-rtb"
    }

}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}


resource "aws_route_table_association" "assoc-rt-subnet" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.myip,var.ansible-ip,var.jenkins-ip]

    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-sg"
    }
}


resource "aws_key_pair" "ssh-key" {
    key_name = "myapp-key"
    public_key = file(var.pub_key_location)
}

resource "aws_instance" "myapp-server" {
    ami = "ami-08f13e5792295e1b2"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail_zone
    /*
    ensures that the EC2 instance is associated with a public IP address. This allows you to connect to the EC2 instance over the internet using SSH from a client outside the VPC where the instance is launched.
    */
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    tags = {
        Name: "dev"
    }
}



output "instance_ip" {
    value = aws_instance.myapp-server.public_ip
}
