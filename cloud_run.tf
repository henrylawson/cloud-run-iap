resource "google_cloud_run_v2_service" "au_syd" {
  project  = var.project
  name     = "http-echo-au-syd"
  location = "australia-southeast1"

  deletion_protection = false

  template {
    containers {
      image = "mendhak/http-https-echo"

      startup_probe {
        failure_threshold     = 5
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 3

        http_get {
          port = 8080
          path = "/?status=startup"
        }
      }

      liveness_probe {
        failure_threshold     = 5
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 3

        http_get {
          port = 8080
          path = "/?status=liveness"
        }
      }
    }
  }

  depends_on = [google_project_service.run, google_project_service.compute, google_project_iam_member.run_user]
}

data "google_iam_policy" "no_auth_syd" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:service-5356697952@gcp-sa-iap.iam.gserviceaccount.com",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "no_auth_syd" {
  location = google_cloud_run_v2_service.au_syd.location
  project  = google_cloud_run_v2_service.au_syd.project
  service  = google_cloud_run_v2_service.au_syd.name

  policy_data = data.google_iam_policy.no_auth_syd.policy_data
}