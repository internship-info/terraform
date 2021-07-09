output "instance_private_ip" {
  value = aws_instance.test-instance.private_ip
}

output "connection_instructions" {
  value = <<EOF
##############################################################################
# Connect to your Linux Virtual Machine
#
# Run the command below to SSH into your server. You can also use PuTTY or any
# other SSH client. Your SSH key is already loaded for you.
##############################################################################
ssh -i <path_to_you_ssh_key> ec2-user@${aws_instance.test-instance.public_ip}
EOF
}