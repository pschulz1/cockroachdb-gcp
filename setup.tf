module "common" {
  source     = "./modules/common"
  region     = var.region
  zone       = [var.zone[0], var.zone[1], var.zone[2]]
  project_id = var.project_id
  node1_id   = module.node1.node_id
  node2_id   = module.node2.node_id
  node3_id   = module.node3.node_id
}

module "node1" {
  source               = "./modules/instances"
  region               = var.region
  zone                 = var.zone[0]
  crdb_version         = var.crdb_version
  node_id              = "1"
  machine_type         = var.machine_type
  service_account      = module.common.service_account_email
  network              = module.common.network
  subnetwork           = module.common.subnetwork
  gce_ssh_user         = var.gce_ssh_user
  gce_ssh_pub_key_file = var.gce_ssh_pub_key_file
}

module "node2" {
  source               = "./modules/instances"
  region               = var.region
  zone                 = var.zone[1]
  crdb_version         = var.crdb_version
  node_id              = "2"
  machine_type         = var.machine_type
  service_account      = module.common.service_account_email
  network              = module.common.network
  subnetwork           = module.common.subnetwork
  gce_ssh_user         = var.gce_ssh_user
  gce_ssh_pub_key_file = var.gce_ssh_pub_key_file
}

module "node3" {
  source               = "./modules/instances"
  region               = var.region
  zone                 = var.zone[2]
  crdb_version         = var.crdb_version
  node_id              = "3"
  machine_type         = var.machine_type
  service_account      = module.common.service_account_email
  network              = module.common.network
  subnetwork           = module.common.subnetwork
  gce_ssh_user         = var.gce_ssh_user
  gce_ssh_pub_key_file = var.gce_ssh_pub_key_file
}

resource "null_resource" "cluster_init" {
  depends_on = [module.common]
  connection {
    type        = "ssh"
    user        = var.gce_ssh_user
    private_key = file(var.gce_ssh_priv_key_file)
    host        = module.node1.node_ip_addr
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 90",
      "sudo -u cockroach cockroach init --insecure --host=crdb-node-1",
      "sudo -u cockroach cockroach sql --insecure -e 'SET CLUSTER SETTING cluster.organization = ${var.org}'",
      "sudo -u cockroach cockroach sql --insecure -e 'SET CLUSTER SETTING enterprise.license = \"${var.license}\"'"
    ]
  }
}

#    "sudo -u cockroach cockroach sql --insecure -e 'CREATE USER demo WITH PASSWORD 'cockroach';'",

