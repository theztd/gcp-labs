terraform {
	required_providers {
		google = {
			source = "hashicorp/google"
		}
	}
}

terraform {
  cloud {
    organization = "theztd-org"

    workspaces {
      name = "gcp-playground"
    }
  }
}

provider "google" {
  credentials = "gcp-key.json"
  project = "playground-redis"
  region  = "eu-central1"
  zone    = "eu-central1-c"
}