# This file generates Ansible inventory file to point at IP address of app box

resource "local_file" "ansible_inventory" {
    filename = "${path.module}/ansible-inventory.yml"
    content = <<-EOF
      fooapp_servers:
        hosts:
          ansible_host: ${aws_instance.app.public_dns}
    EOF
}
