data "aws_ami" "ubuntu" {
	most_recent = true

	filter {
		name   = "name"
		values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
	}

	filter {
		name   = "virtualization-type"
		values = ["hvm"]
	}

	owners = ["099720109477"]
}

data "aws_key_pair" "my_key" {
	key_name = var.key_name
}

resource "aws_instance" "crowdsec_instance" {
	ami 		 = data.aws_ami.ubuntu.id
	key_name = data.aws_key_pair.my_key.key_name
	associate_public_ip_address = true
	instance_type = "t3.micro"

	vpc_security_group_ids = [aws_security_group.ec2-instance.id]

	subnet_id = var.subnet

	iam_instance_profile = aws_iam_instance_profile.ec2_profile.name	
}

resource "aws_iam_instance_profile" "ec2_profile" {
	name = "crowdsec-ec2-profile"
	role = aws_iam_role.ec2_role.name
}

output "ec2_instance_ip" {
	value = aws_instance.crowdsec_instance.public_ip
}