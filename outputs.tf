output "ec2_ip_one" {
  value = module.utkal_ec2_instance.ec2_instance_one.public_ip
}

output "ec2_ip_two" {
  value = module.utkal_ec2_instance.ec2_instance_two.public_ip
}


output "ec2_ip_three" {
  value = module.utkal_ec2_instance.ec2_instance_three.public_ip
}

