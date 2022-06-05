resource "aws_vpc" "sand" {
  provider   = aws.master
  cidr_block = "172.30.0.0/16"
  tags = {
    name = "instant-status-vpc"
  }
}

data "aws_availability_zones" "azs" {
  provider = aws.master
  state    = "available"
}

resource "aws_subnet" "PublicSubnet1" {
  provider          = aws.master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.sand.id
  cidr_block        = "172.30.1.0/24"
  tags = {
    name = "PublicSubnet1"
  }
}

resource "aws_subnet" "PublicSubnet2" {
  provider          = aws.master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.sand.id
  cidr_block        = "172.30.2.0/24"
  tags = {
    name = "PublicSubnet2"
  }
}

resource "aws_subnet" "PublicSubnet3" {
  provider          = aws.master
  availability_zone = element(data.aws_availability_zones.azs.names, 2)
  vpc_id            = aws_vpc.sand.id
  cidr_block        = "172.30.3.0/24"
  tags = {
    name = "PublicSubnet3"
  }
}

resource "aws_subnet" "PrivateSubnet1" {
  provider          = aws.master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.sand.id
  cidr_block        = "172.30.4.0/24"
  tags = {
    name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "PrivateSubnet2" {
  provider          = aws.master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.sand.id
  cidr_block        = "172.30.5.0/24"
  tags = {
    name = "PrivateSubnet2"
  }
}

resource "aws_subnet" "PrivateSubnet3" {
  provider          = aws.master
  availability_zone = element(data.aws_availability_zones.azs.names, 2)
  vpc_id            = aws_vpc.sand.id
  cidr_block        = "172.30.6.0/24"
  tags = {
    name = "PrivateSubnet3"
  }
}

resource "aws_internet_gateway" "igw" {
  provider = aws.master
  vpc_id   = aws_vpc.sand.id
  tags = {
    name = "igw"
  }
}

#Create public route table 
resource "aws_route_table" "public_route" {
  provider = aws.master
  vpc_id   = aws_vpc.sand.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "public_route"
  }
}

resource "aws_route_table_association" "PublicSubnet1" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "PublicSubnet2" {
  subnet_id      = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "PublicSubnet3" {
  subnet_id      = aws_subnet.PublicSubnet3.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_eip" "eip_nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.PublicSubnet2.id

  tags = {
    Name = "NAT"
  }
  depends_on = [aws_internet_gateway.igw]
}

#Create private route table 
resource "aws_route_table" "private_route" {
  provider = aws.master
  vpc_id   = aws_vpc.sand.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "private_route"
  }
}

resource "aws_route_table_association" "PrivateSubnet1" {
  subnet_id      = aws_subnet.PrivateSubnet1.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "PrivateSubnet2" {
  subnet_id      = aws_subnet.PrivateSubnet2.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "PrivateSubnet3" {
  subnet_id      = aws_subnet.PrivateSubnet3.id
  route_table_id = aws_route_table.private_route.id
}

# Creating Database Subnet group for RDS under our VPC
resource "aws_db_subnet_group" "db_subnet" {
  name       = "rds_db"
  subnet_ids = [aws_subnet.PrivateSubnet1.id, aws_subnet.PrivateSubnet2.id, aws_subnet.PrivateSubnet3.id ]
  tags = {
    Name = "My DB subnet group"
  }
}