resource "google_compute_global_address" "gclb" {
  provider = google-beta
  project  = var.project
  name     = "http-echo"
}

resource "google_compute_global_forwarding_rule" "gclb" {
  project               = var.project
  name                  = "http-echo"
  provider              = google-beta
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.gclb.id
  ip_address            = google_compute_global_address.gclb.id
}

resource "google_compute_target_https_proxy" "gclb" {
  project         = var.project
  name            = "http-echo"
  provider        = google-beta
  url_map         = google_compute_url_map.gclb.id
  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.http_echo.id}"
}

resource "google_compute_url_map" "gclb" {
  project         = var.project
  name            = "http-echo"
  provider        = google-beta
  default_service = google_compute_backend_service.gclb.id
}

resource "google_compute_backend_service" "gclb" {
  project = var.project
  name    = "http-echo"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  iap {
    enabled = true
  }

  backend {
    group = google_compute_region_network_endpoint_group.syd_neg.id
  }
}

resource "google_compute_region_network_endpoint_group" "syd_neg" {
  project               = var.project
  name                  = "http-echo"
  network_endpoint_type = "SERVERLESS"
  region                = "australia-southeast1"
  depends_on            = [google_project_service.compute]

  cloud_run {
    service = google_cloud_run_v2_service.au_syd.name
  }
}

resource "google_certificate_manager_certificate" "http_echo" {
  project = var.project

  name  = "http-echo"
  scope = "DEFAULT"

  managed {
    domains = ["http-echo.foinq.com"]
  }
}

resource "google_certificate_manager_certificate_map" "http_echo" {
  project = var.project

  name = "http-echo"
}

resource "google_certificate_manager_certificate_map_entry" "http_echo" {
  project = var.project

  name = "http-echo"

  map = google_certificate_manager_certificate_map.http_echo.name

  certificates = [google_certificate_manager_certificate.http_echo.id]
  hostname     = "http-echo.foinq.com"
}
