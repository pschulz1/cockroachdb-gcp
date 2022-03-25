terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.20.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.2.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  #Assumes auth via gloud "gcloud auth application-default login"
}