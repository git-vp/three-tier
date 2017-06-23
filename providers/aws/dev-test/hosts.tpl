[bastion]
bast ansible_ssh_host=${bastion_ip} ansible_ssh_user=${user} ansible_ssh_private_key_file=${bastion_key}

[appservers]
app-01 ansible_ssh_host=${app_ip} ansible_ssh_private_key_file=${app_key} 

[appservers:vars]
ansible_ssh_common_args=' -o ProxyCommand=\"ssh -i ${bastion_key} -W %h:%p ubuntu@${bastion_ip}\"'
ansible_ssh_user=${user}


