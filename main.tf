#----------------------------------------------------
# 1. New VPC - create it                                     -----DONE
# 2. Subnet 100.100.100.0/24 for VPC + auto-assign public ip -----DONE
# 3. Internet Gateway for VPC and attach                     -----DONE
# 4. Security group - allow ssh, icmp and 51820 for WG       -----DONE
# 5. VM - with VPC, subnet, default security groups          -----DONE

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "myvpnproject-vpc" {                               #-----new VPC
  cidr_block = "100.100.100.0/24"
  enable_dns_hostnames = true
  tags = {
    Name = "myvpnproject-vpc"
  }
}

resource "aws_internet_gateway" "myvpnproject-vpc-IG" {              #----- new internet gateway for vpc
  vpc_id = aws_vpc.myvpnproject-vpc.id
  tags = {
    "Name" = "myvpnproject-vpc-IG"
  }
}

resource "aws_subnet" "myvpnproject-vpc-subnet" {                    #----- subnet for VPC
  vpc_id = aws_vpc.myvpnproject-vpc.id
  cidr_block = "100.100.100.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "myvpnproject-vpc-subnet"
  }
}

resource "aws_route" "myvpnproject-vpc-IGroute" {                    #----- route to the internet through internet gateway
  route_table_id = aws_vpc.myvpnproject-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.myvpnproject-vpc-IG.id
}

resource "aws_security_group_rule" "myvpnproject-vpc-SGrule-ssh" {   #----- ssh rule for security group
  security_group_id = aws_vpc.myvpnproject-vpc.default_security_group_id
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "myvpnproject-vpc-SGrule-WG" {  #----- WGVPN rule for security group
  security_group_id = aws_vpc.myvpnproject-vpc.default_security_group_id
  type = "ingress"
  from_port = 51820
  to_port = 51820
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "myvpnproject-vpc-SGrule-ICMP" {  #----- ICMP rule for security group
  security_group_id = aws_vpc.myvpnproject-vpc.default_security_group_id
  type = "ingress"
  from_port = -1
  to_port = -1
  protocol = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "myvpnproject-AMI" {                      #----- making AMI instance
  ami = "ami-0a2dc38dc30ba417e"                                   #----- CentOS 8
  instance_type = "t2.micro"
  subnet_id = aws_subnet.myvpnproject-vpc-subnet.id
  vpc_security_group_ids = [aws_vpc.myvpnproject-vpc.default_security_group_id]
  key_name = "lab02"

  private_ip = "100.100.100.10"

  root_block_device {
    volume_size = "15"
  }
  tags = {
    "Project" = "MyWGVPNTestServer",
    "Name" = "WGVPN-Test1",
    "ServerType" = "vpn_server"
  }

  provisioner "remote-exec" {                               #----- trying to ssh to self until ssh is available, therefore, we can execute ansible
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type = "ssh"
      user = "centos"
      private_key = "${file("lab02.pem")}"
      host = aws_instance.myvpnproject-AMI.public_ip
    }
  }
}