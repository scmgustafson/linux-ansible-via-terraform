output "nginx_webserver_address" {
  value = "Visit Nginx Webpage Here: http://${aws_instance.managed_node1.public_dns}"
}

output "apache_webserver_address" {
  value = "Visit Apache Webpage Here: http://${aws_instance.managed_node2.public_dns}"
}