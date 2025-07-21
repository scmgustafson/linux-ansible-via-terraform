#!/bin/bash

# Create a copy of the demo SSH private key for use with Ansible
cat <<EOF >/root/.ssh/id_rsa
${private_key}
EOF
chmod 600 /root/.ssh/id_rsa

# Install Ansible
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
python3 -m pip install ansible