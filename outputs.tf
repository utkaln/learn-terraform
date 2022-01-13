output "ec2_ip" {
  value = module.utkal_ec2_instance.ec2_instance.public_ip
}
