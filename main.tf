# Create VPC
resource "aws_vpc" "elastic_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "elastic-vpc"
  }
}

# Create 2 public subnets
resource "aws_subnet" "elastic_pub_subnet_1" {
  vpc_id            = aws_vpc.elastic_vpc.id
  cidr_block        = var.public_subnet_1_cidr_block
  availability_zone = var.availability_zone_1
  tags = {
    Name = "elasticpubsub1"
  }
}

resource "aws_subnet" "elastic_pub_subnet_2" {
  vpc_id            = aws_vpc.elastic_vpc.id
  cidr_block        = var.public_subnet_2_cidr_block
  availability_zone = var.availability_zone_2
  tags = {
    Name = "elasticpubsub2"
  }
}

# Create 2 private subnets
resource "aws_subnet" "elastic_priv_subnet_1" {
  vpc_id            = aws_vpc.elastic_vpc.id
  cidr_block        = var.private_subnet_1_cidr_block
  availability_zone = var.availability_zone_1
  tags = {
    Name = "elasticprisub1"
  }
}

resource "aws_subnet" "elastic_priv_subnet_2" {
  vpc_id            = aws_vpc.elastic_vpc.id
  cidr_block        = var.private_subnet_2_cidr_block
  availability_zone = var.availability_zone_2
  tags = {
    Name = "elasticprisub2"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.elastic_vpc.id
  tags = {
    Name = "igw"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "gateway" {
  tags = {
    Name = "gateway-eip"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "gateway" {
  allocation_id = aws_eip.gateway.id
  subnet_id     = aws_subnet.elastic_pub_subnet_1.id
  tags = {
    Name = "gateway"
  }
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.elastic_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.elastic_pub_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.elastic_pub_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.elastic_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gateway.id
  }

  tags = {
    Name = "private_route_table"
  }
}

# Associate Private Route Table with Private Subnets
resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.elastic_priv_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.elastic_priv_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Security Group for Public Instances (Bastion Host)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for bastion instances"
  vpc_id      = aws_vpc.elastic_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Private Instances (Elastic)
resource "aws_security_group" "elastic_sg" {
  name        = "elastic_sg"
  description = "Security group for elastic instances"
  vpc_id      = aws_vpc.elastic_vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 8200
    to_port          = 8200
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port        = 9200
    to_port          = 9200
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Optional Internal Communication Security Group
resource "aws_security_group" "internal_sg" {
  name        = "internal_sg"
  description = "Security group for internal communication"
  vpc_id      = aws_vpc.elastic_vpc.id

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create public instances with t2.medium and tags
resource "aws_instance" "public_instance_1" {
  ami                    = "ami-085f9c64a9b75eed5"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.elastic_pub_subnet_1.id
  key_name               = "tool"  # Update this line to use the existing key pair
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true  

  tags = {
    Name = "Elasticsearch1"
  }
}

resource "aws_instance" "public_instance_2" {
  ami                    = "ami-085f9c64a9b75eed5"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.elastic_pub_subnet_2.id
  key_name               = "tool"  # Update this line to use the existing key pair
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "Elastic2"
  }
}


# Create private instances with t2.micro and tags
resource "aws_instance" "private_instance_1" {
  ami                    = "ami-085f9c64a9b75eed5"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.elastic_priv_subnet_1.id
  vpc_security_group_ids = [aws_security_group.elastic_sg.id]

  tags = {
    Name = "Private1"
  }
}

resource "aws_instance" "private_instance_2" {
  ami                    = "ami-085f9c64a9b75eed5"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.elastic_priv_subnet_2.id
  vpc_security_group_ids = [aws_security_group.elastic_sg.id]

  tags = {
    Name = "Private2"
  }
}
