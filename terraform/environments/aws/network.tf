# ==========================================
# 1. CREATE VPC : create a VPC with a specified CIDR block and enable DNS support and hostnames.
# ==========================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true ## Enable DNS support for the VPC
  enable_dns_hostnames = true ## Enable DNS hostnames for instances in the VPC

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}


# ==========================================
# 2. CREATE PUBLIC SUBNETS : for the public subnets, create subnets that will host resources that require direct internet access, such as load balancers or bastion hosts.
# ==========================================

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                     = "${var.project_name}-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  })
}


# ==========================================
# 3. CREATE PRIVATE SUBNETS : for the private subnets, create subnets that will host resources that do not require direct internet access, such as databases or application servers.
# ==========================================

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name                              = "${var.project_name}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
  })
}


# ==========================================
# 4. CREATE INTERNET GATEWAY : for the public subnets, create an Internet Gateway to allow inbound and outbound internet traffic.
# ==========================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw"
  })
}


# ==========================================
# 5. CREATE PUBLIC ROUTE TABLE : for the public subnets, create a route table that directs internet-bound traffic to the Internet Gateway.
# ==========================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}


# ==========================================
# 6. ASSOCIATE PUBLIC SUBNETS : for each public subnet, associate it with the public route table to enable internet access.
# ==========================================

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# ==========================================
# 7. CREATE ELASTIC IP FOR NAT GATEWAY : for the NAT Gateway, create an Elastic IP address to allow outbound internet access for private subnets.
# ==========================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-eip"
  })
}


# ==========================================
# 8. CREATE NAT GATEWAY : A NAT Gateway allows private resources to initiate outbound internet connections without accepting unsolicited inbound internet connections.
# ==========================================

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat"
  })

  depends_on = [
    aws_internet_gateway.main
  ]
}


# ==========================================
# 9. CREATE PRIVATE ROUTE TABLES : for the private subnets, create route tables that direct internet-bound traffic to the NAT Gateway.
# ==========================================

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
  })
}


# ==========================================
# 10. ASSOCIATE PRIVATE SUBNETS : for each private subnet, associate it with the corresponding private route table to enable outbound internet access through the NAT Gateway.
# ==========================================

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}