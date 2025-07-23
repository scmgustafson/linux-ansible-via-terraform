# Ansible on latest Amazon Linux via Terraform Demo

## Description

This project aims to demo bootstrapping a functional Ansible setup on AWS with Terraform.
It serves to showcase the necessary Terraform configurations to create the different nodes and the usage of Ansible to manage them.

In this example, we will create 3 nodes. 1 Ansible control node and 2 managed nodes.
Ansible will be used to provision and deploy a simple web page on the 2 managed nodes using Apache and Nginx. Additionally, the system packages will be updated and a sample user will be created.

## Requirements/Dependencies:

To run this project, you will need:

- Terraform version >= 1.12
- Current latest provider versions of AWS, TLS, Local, and Null (automatically installed on `terraform init`)
- AWS CLI and/or AWS credentials ready for Terraform to use

## Instructions for Use

_Note: This project will create and utilize an ephemeral SSH key in your local directory. Please remember to `terraform destroy` your resources when finished_

Initialize and apply Terraform configuration

1. `terraform init`
2. `terraform apply`

## How to Test

Test from Terraform via remote-exec:

1. Uncomment the `"null_resource" "ansible_test"` resource block at the end of main.tf
2. Run a `terraform apply` and allow the new null_resource to create
3. Check the output for the stdout of an `ansible ping` command (you should see "web1 | SUCCESS ...")

View the content of the 2 managed web servers:
