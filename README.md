## ABOUT

This module is intended as an example of how a self-hosted CockroachDB cluster could be provisioned on GCP.
The module is pretty much self-contained and deploys CockroachDB in a non.production mode, using the --inscure flag!


## Prerequisites

1. Terraform - Download and install https://learn.hashicorp.com/tutorials/terraform/install-cli
2. gcloud - Having gcloud installed and being authenticated on the machine which will execute the Terraform configuration. Otherwise you will need to modify the provider.tf and feed your secrets to the GCP provider resource. 
4. SSH key pair - For now this is external to the module. A key can be quickly generated via:

openssl genrsa -out key.pem 2048<br/>
openssl rsa -in key.pem -outform PEM -pubout -out public.pem

## Tunable Variables

The following Terraform variables must be set in order to ensure functionality of the module

* project_id - GCP Project ID
* crdb_version - Desired CockroachDB Version
* gce_ssh_user - SSH user to be configured inside the instances
* gce_ssh_pub_key_file - Path to SSH cert file (added to the GCP instances OS)
* gce_ssh_priv_key_file - Path to SSH key file (used to connect to the instance)
* org - CockroachDB og in the license
* license - CockroachDB Enterprise license

## Usage

1. terraform init
2. terraform apply -auto-approve
3. terraform will output the load-balancer IP to connect to the UI <IP>:8080
