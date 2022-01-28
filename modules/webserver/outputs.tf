output "ec2_instance_one" {
  value = aws_instance.ansible-EC2-one
}

output "ec2_instance_two" {
  value = aws_instance.ansible-EC2-two
}

output "ec2_instance_three" {
  value = aws_instance.ansible-EC2-three
}

output "ec2_instance_exclude" {
  value = aws_instance.ansible-EC2-exclude
}
