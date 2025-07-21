output "ansible_control_node_public_ip" {
  value = aws_instance.control_node.public_ip
}

output "ansible_control_node_private_dns" {
  value = aws_instance.control_node.private_dns
}

output "ansible_managed_node_private_dns" {
  value = aws_instance.managed_node.private_dns
}