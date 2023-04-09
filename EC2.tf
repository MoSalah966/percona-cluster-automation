# Create a key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair"
  public_key = file("C:/Users/user-7/Downloads/keypairforterraform/my-key-pair.pub")
}

# Create a security group for the private subnet
resource "aws_security_group" "private_sg" {
  name_prefix = "private_sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

# Create a security group for the bastion host
resource "aws_security_group" "bastion_sg" {
  name_prefix = "bastion_sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private.cidr_block]
  }
}

# Launch a bastion host in the public subnet
resource "aws_instance" "bastion" {
  ami           = "ami-0aa2b7722dc1b5612"  # Amazon ubuntu 20.04
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "bastion"
  }
}

# Launch master instance in the private subnet
resource "aws_instance" "master" {
  count         = 1
  ami           = "ami-0aa2b7722dc1b5612"  # Amazon ubuntu 20.04
  instance_type = "t2.medium"
  key_name      = aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  subnet_id     = aws_subnet.private.id

  tags = {
    Name = "private-${count.index}"
  }
}

# Launch 2 instances in the private subnet
resource "aws_instance" "private" {
  count         = 2
  ami           = "ami-0aa2b7722dc1b5612"  # Amazon ubuntu 20.04
  instance_type = "t2.medium"
  key_name      = aws_key_pair.my_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  subnet_id     = aws_subnet.private.id

  tags = {
    Name = "private-${count.index}"
  }
}