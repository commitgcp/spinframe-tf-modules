# Pub/Sub Topic
resource "google_pubsub_topic" "app_topic" {
  name       = "${var.name}-topic"
  project    = var.project_id
  depends_on = [google_project_service.project_services]
}

# IAM Binding to allow the service account to publish to the topic
resource "google_pubsub_topic_iam_binding" "pubsub_publisher" {
  topic = google_pubsub_topic.app_topic.name
  role  = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${google_service_account.mig_sa.email}"
  ]
  depends_on = [google_project_service.project_services]
}
