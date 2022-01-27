
// Create a security group
resource "aws_security_group" "utkal_sg" {
  name        = "utkal_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  // Inbound rule for SSH access to local laptop  
  ingress {
    description = "SSH from Local laptop"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ip
  }

  // Inbound rule for HTTP access for everyone
  ingress {
    description = "HTTP from everywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.http_ip
  }

  // Outbound rule to not limit any port or any protocol
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}


// First choose AMI for the instance with the filter
data "aws_ami" "utkal-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = var.image_name
  }

}

resource "aws_key_pair" "utkal-key-pair" {
  // Create a key name through which it can be referred
  key_name = "learn-terraform-key"

  // this is the local public key located in .ssh/id_rsa_pub 
  public_key = file(var.public_key_location)
}

resource "aws_instance" "utkal-EC2" {
  // Use the ami id that matches the desired description
  ami = data.aws_ami.utkal-ami.id

  // drive instance type as a parameter for flexibility
  instance_type = var.instance_type

  // subnet id should match to the subnet created above in the custom vpc
  subnet_id = var.subnet_from_module_id

  // associated the configured SG above
  vpc_security_group_ids = [aws_security_group.utkal_sg.id]

  // associate AZ to be in the same AZ as that of the subnet above
  availability_zone = var.def_az

  // Allow external IP to access the instance
  associate_public_ip_address = true

  // Associate the key pair to be able to allow access to the instance via SSH
  key_name = aws_key_pair.utkal-key-pair.key_name

  // Start up script in the instance
  //user_data = file("./bootstrap.sh")

  tags = {
    Name = "${var.env_prefix}-server-instance"
  }
}


