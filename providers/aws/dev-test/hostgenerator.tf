variable "filename" {
  default = "hosts"
}

data "template_file" "ansible_host_generator" {
  template = "${file("${path.cwd}/hosts.tpl")}"

  vars {
    bastion_ip = "${module.bastion.bastion_public_ip}"
    app_ip = "${module.app1.private_ip}"
    bastion_key = "/vagrant/Workspace/Keys/bastkey"
    app_key = "/vagrant/Workspace/Keys/appkey"
    user = "ubuntu"
  }
}

data "template_cloudinit_config" "output" {
  gzip = false
  base64_encode = false

  part {
    filename = "${var.filename}"
    content_type = "text"
    content = "${data.template_file.ansible_host_generator.rendered}"
  }
}

resource "null_resource" "local" {
  triggers {
    template = "${data.template_file.ansible_host_generator.rendered}"
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.ansible_host_generator.rendered}\" > ${path.cwd}/${var.filename}"
  }
}

output "rendered" {
  value = "${data.template_file.ansible_host_generator.rendered}"
}
