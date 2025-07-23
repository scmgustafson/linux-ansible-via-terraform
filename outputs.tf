output "ansible_control_node_public_ip" {
  value = aws_instance.control_node.public_ip
}

output "ansible_control_node_private_dns" {
  value = aws_instance.control_node.private_dns
}

output "ansible_managed_node1_private_dns" {
  value = aws_instance.managed_node1.private_dns
}

output "ansible_managed_node2_private_dns" {
  value = aws_instance.managed_node2.private_dns
}

output "ansible_managed_node1_public_ip" {
  value = aws_instance.managed_node1.public_ip
}

output "ansible_managed_node2_public_ip" {
  value = aws_instance.managed_node2.public_ip
}