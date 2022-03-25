variable "project_id" {
    default = "patrick-schulz-332212"
    description = "GCP project ID"
}
variable "machine_type" {
    default = "e2-medium"
    description = "Size of the GCP instance"
}
variable "region" {
    default = "us-east4"
    description = "GCP region"
}
variable "zone" {
  type = list(string)
  default = ["us-east4a", "us-east4b", "us-east4c"]
}
variable "crdb_version" {
    default = "v21.2.0"
    description = "Required CRDB version to be downloaded upon setup"
}
variable "node_id" {
    default = ""
    description = "Will be used as part of the host naming"
}
variable "network" {
    default = ""
    description = "New GCP network inside the given GCP project"
}
variable "subnetwork" {
    default = ""
    description = "Subnetwork to place instances into"
}
variable "service_account" {
    default = "crdb-service-account"
}
variable "gce_ssh_user" {
    default = "patrick"
    description = "SSH user to be added to the instance"
}
variable "gce_ssh_pub_key_file" {
    default = "/Users/patrick/.ssh/gce_public_key.pub"
    description = "Path to SSH public key to be added into the instance"
}
variable "gce_ssh_priv_key_file" {
    default = "/Users/patrick/.ssh/gce_private_key.pem"
    description = "Path to SSH private key in order to connect to instances"
}
variable "org" {
    default = "PatrickSchulz"
    description = "CRDB Enterprise license org."
}
variable "license" {
    default = "crl-0-EPC5w44GGAIiDVBhdHJpY2tTY2h1bHo"
    description = "CRDB Enterprise license"
}