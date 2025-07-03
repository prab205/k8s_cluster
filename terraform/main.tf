provider "aws" {
  region = var.aws_region
}

module "basic_infrastructure" {
  source            = "./module/dependencies"
  source_cidr_block = ["0.0.0.0/0"]
  ingress_ports     = [22, 80, 443, 3000, 6443, 2379, 2380, 10250, 10257, 10259]
}

resource "aws_key_pair" "my_key" {
  key_name   = "prabin_test"
  public_key = file(var.ssh_public_key_path)
}

data "aws_ami" "ubuntu_2204" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical (Ubuntu)
}

locals {
  selected_ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu_2204.id
}

resource "aws_instance" "prabin" {
  count = var.no_of_nodes

  associate_public_ip_address = true
  source_dest_check           = false
  instance_type               = var.instance_type
  ami                         = local.selected_ami_id
  key_name                    = aws_key_pair.my_key.key_name
  user_data_base64            = filebase64("./resources/user_data.sh")
  subnet_id                   = module.basic_infrastructure.public_subnet_a_id
  vpc_security_group_ids      = [module.basic_infrastructure.security_group_id]
  iam_instance_profile        = module.basic_infrastructure.ec2_instance_profile_name

  root_block_device {
    volume_size = 15
  }

  tags = {
    Name                               = "prabin-test"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

}

resource "null_resource" "generate_ansible_inventory" {
  triggers = {
    value = aws_instance.prabin[var.no_of_nodes - 1].public_ip
  }

  provisioner "local-exec" {
    command = <<EOT
      bash -c '
        echo "[master]" > ${var.ansible_directory}/inventory
        echo "${element(aws_instance.prabin.*.public_ip, 0)}" >> ${var.ansible_directory}/inventory
        echo "[worker]" >> ${var.ansible_directory}/inventory
        for ip in ${join(" ", slice(aws_instance.prabin.*.public_ip, 1, var.no_of_nodes))}; do
          echo "$ip" >> ${var.ansible_directory}/inventory
        done
      '
    EOT
  }

  depends_on = [aws_instance.prabin]

}

resource "null_resource" "run_ansible" {
  triggers = {
    value = aws_instance.prabin[var.no_of_nodes - 1].public_ip
  }

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = aws_instance.prabin[var.no_of_nodes - 1].public_dns
    }

  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i ${var.ansible_directory}/inventory --private-key ${var.ssh_private_key_path} ${var.ansible_directory}/main.yml"
  }

  depends_on = [null_resource.generate_ansible_inventory]
}