# Ansible on latest Amazon Linux via Terraform Demo

## Description

This project aims to demo bootstrapping a functional Ansible setup on AWS with Terraform.
It serves to showcase the necessary Terraform configurations and the usage of Ansible to manage some different nodes.

Node examples:

- Nginx
- Etc
- Etc

## Requirements/Dependencies:

To run this project, you will need:

- Terraform version >= 1.12
- Current latest provider versions of AWS, TLS, Local, and Null (automatically installed on `terraform init`)

## Instructions for Use

Initialize and apply Terraform configuration

1. `terraform init`
2. `terraform apply`

## How to Test

Test from Terraform via remote-exec

1. Uncomment the `"null_resource" "ansible_test"` resource block at the end of main.tf
2. Run a `terraform apply` and allow the new null_resource to create
3. Check the output for the stdout of an `ansible ping` command (you should see "web | SUCCESS ...")
