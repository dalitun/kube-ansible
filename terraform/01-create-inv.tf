resource "null_resource" "ansible-provision" {
  depends_on = ["openstack_compute_instance_v2.k8s-master","openstack_compute_instance_v2.k8s-node"]
  
  ##Create Masters Inventory
  provisioner "local-exec" {
    command =  "echo \"[masters]\n${openstack_compute_instance_v2.k8s-master.name} ansible_ssh_host=${openstack_compute_floatingip_v2.master-ip.address} ansible_ssh_user=cloud ansible_ssh_private_key_file=~/.ssh/alikey.pem\" > ../inventory/inventory"
  }

  ##Create ETCD Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[etcd]\n${openstack_compute_instance_v2.k8s-master.name} ansible_ssh_host=${openstack_compute_floatingip_v2.master-ip.address} ansible_ssh_user=cloud ansible_ssh_private_key_file=~/.ssh/alikey.pem\" >> ../inventory/inventory"
  }

  ##Create sslhostInventory
    provisioner "local-exec" {
      command =  "echo \"\n[sslhost]\n${openstack_compute_instance_v2.k8s-master.name} ansible_ssh_host=${openstack_compute_floatingip_v2.master-ip.address} ansible_ssh_user=cloud ansible_ssh_private_key_file=~/.ssh/alikey.pem\" >> ../inventory/inventory"
    }



  ##Create Nodes Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[nodes]\" >> ../inventory/inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_host=%s", openstack_compute_instance_v2.k8s-node.*.name, openstack_compute_floatingip_v2.node-ip.*.address))} ansible_ssh_user=cloud ansible_ssh_private_key_file=~/.ssh/alikey.pem\" >>../inventory/inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"\n[cluster:children]\nnodes\nmasters\" >>../inventory/inventory"
  }
}
