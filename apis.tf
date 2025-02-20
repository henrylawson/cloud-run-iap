resource "google_project_service" "run" {
  project                    = var.project
  service                    = "run.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service_identity" "run" {
  provider = google-beta

  project = google_project_service.run.project
  service = google_project_service.run.service
}

resource "google_project_iam_member" "run_user" {
  project = var.project
  role    = "roles/run.serviceAgent"
  member  = "serviceAccount:${google_project_service_identity.run.email}"
}

resource "google_project_service" "compute" {
  project = var.project
  service = "compute.googleapis.com"
}

resource "google_project_service_identity" "compute" {
  provider = google-beta

  project = google_project_service.compute.project
  service = google_project_service.compute.service
}

resource "google_project_service" "iap" {
  project = var.project
  service = "iap.googleapis.com"
}

resource "google_project_service_identity" "iap" {
  provider = google-beta

  project = google_project_service.iap.project
  service = google_project_service.iap.service
}

resource "google_project_service" "certificatemanager" {
  project = var.project
  service = "certificatemanager.googleapis.com"
}