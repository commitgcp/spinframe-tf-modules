# Pub/Sub Topic
resource "google_pubsub_topic" "app_topic" {
  name    = "${var.name}-topic"
  project = var.project_id
}

# IAM Binding to allow the service account to publish to the topic
resource "google_pubsub_topic_iam_binding" "pubsub_publisher" {
  topic = google_pubsub_topic.app_topic.name
  role  = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${module.mig_with_https_lb.mig_service_account}"
  ]
}
