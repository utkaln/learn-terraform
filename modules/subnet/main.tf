

// Create subnet and associate with the VPC created above
// Reads CIDR block from the var files
resource "aws_subnet" "utkal-subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.def_az

  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}


// Create a custom route table to allow https traffic from outside
// RT also allows port 22 access from outside for SSH access
// Declare the ports to be open from outside

resource "aws_route_table" "utkal-rt" {
  vpc_id = var.vpc_id
  route {
    // default for VPC is created implicitly
    // start with Internet Gateway
    cidr_block = var.rt_outside
    gateway_id = aws_internet_gateway.utkal-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rt-1"
  }
}


// Internet Gateway is required for Route Table to access to internet
resource "aws_internet_gateway" "utkal-igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

// Associate custom route table with the subnet created above
resource "aws_route_table_association" "utkal-rt-associate" {
  subnet_id      = aws_subnet.utkal-subnet.id
  route_table_id = aws_route_table.utkal-rt.id
}
