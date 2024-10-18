resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "defaultIGW" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_eip" "my_elastic_ip" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "my_nat_gtw" {
  allocation_id = aws_eip.my_elastic_ip.id
  subnet_id     = values(aws_subnet.public_subnets)[0].id

  tags = {
    Name = "NAT Gateway"
  }
}

// Public Subnet
resource "aws_subnet" "public_subnets" {
  for_each                = toset(var.vpc_public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = var.vpc_azs[index(var.vpc_public_subnets, each.value)]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${index(var.vpc_public_subnets, each.value) + 1}"
  }
}

// Private Subnet
resource "aws_subnet" "private_subnets" {
  for_each          = toset(var.vpc_private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = var.vpc_azs[index(var.vpc_private_subnets, each.value)]

  tags = {
    Name = "Private Subnet ${index(var.vpc_private_subnets, each.value) + 1}"
  }
}

// create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.defaultIGW.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

// create private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private Route Table"
  }
}

## public subnet Association
resource "aws_route_table_association" "public_subnets_associations" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

## private subnet Association
resource "aws_route_table_association" "private_subnets_associations" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route" "route_nat_gw" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gtw.id

  timeouts {
    create = "5m"
  }
}