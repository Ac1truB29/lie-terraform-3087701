data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.blog.id]

  tags = {
    Name = "HelloWorld"
  }
}

 # module "blog_sg" {
   # source  = "terraform-aws-modules/security-group/aws"
   # version = "5.1.0"
   # name    = "blog_new"

   # vpc_id = data.aws_vpc.default.id
  
   # ingress_rules       = ["http-80-tcp", "https-443"]
   # ingress_cidr_blocks = ["0.0.0.0/0"]

   #  egress_rules       = ["all-all"]
   #  egress_cidr_blocks = ["0.0.0.0/0"]
  # }


  
module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  vpc_id  = data.aws_vpc.default.id
  name    = "blog"
  ingress_rules = ["https-443-tcp","http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}





resource "aws_security_group" "blog" {
  name        = "blog"
  description = " Allow http and https in. Allow everything out"

  vpc_id = data.aws_vpc.default.id 
}

resource "aws_vpc_security_group_ingress_rule" "blog_http_in" {
  # type        = "ingress"
  from_port   = 80
  to_port     = 80
  ip_protocol    = "tcp" 
   cidr_ipv4 = "0.0.0.0/0"

  security_group_id = aws_security_group.blog.id
}

resource "aws_vpc_security_group_ingress_rule" "blog_https_in" {
  # type        = "ingress"
  from_port   = 443
  to_port     = 443
  ip_protocol    = "tcp" 
  cidr_ipv4 = "0.0.0.0/0"

  security_group_id = aws_security_group.blog.id
}

 resource "aws_vpc_security_group_egress_rule" "blog_everything_out" {
  # type        = "egress"
   ip_protocol    = -1 
   cidr_ipv4 = "0.0.0.0/0"

   security_group_id = aws_security_group.blog.id
 }