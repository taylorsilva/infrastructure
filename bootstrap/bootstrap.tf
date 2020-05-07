provider "google" {
  project = "cf-concourse-production"
  region  = "us-central1"
}

resource "google_storage_bucket" "concourse_greenpeace" {
  name = "concourse-greenpeace"
  bucket_policy_only = true
}

resource "google_service_account" "greenpeace_terraform" {
  account_id   = "greenpeace-terraform"
  display_name = "Greenpeace Terraform"
  description  = "Used by Terraform to perform updates to our deployments."
}

resource "google_storage_bucket_iam_member" "greenpeace_state_policy" {
  bucket = google_storage_bucket.concourse_greenpeace.name
  role = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.greenpeace_terraform.email}"
}

resource "google_project_iam_member" "greenpeace_terraform_policy" {
  for_each = {
    "compute" = "roles/compute.admin"
    "cloudsql" = "roles/cloudsql.admin"
    "container" = "roles/container.admin"
    "dns" = "roles/dns.admin"
    "networks" = "roles/servicenetworking.networksAdmin"
    "storage" = "roles/storage.admin"
    "serviceAccountAdmin" = "roles/iam.serviceAccountAdmin"
    "iamAdmin" = "roles/resourcemanager.projectIamAdmin"

    # needed for vault
    "kmsAdmin" = "roles/cloudkms.admin"
    "kmsEncrypt" = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

    # needed for creating node pools
    "serviceAccountUser" = "roles/iam.serviceAccountUser"

    "secretManager" = "roles/secretmanager.admin"
  }

  role = each.value
  member = "serviceAccount:${google_service_account.greenpeace_terraform.email}"
}