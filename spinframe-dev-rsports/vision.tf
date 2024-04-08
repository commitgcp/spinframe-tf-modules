resource "google_project_iam_member" "service_account_visionai_admin" {
  project = var.project_id
  role    = "roles/visionai.admin"
  member  = "serviceAccount:${module.mig_with_https_lb.mig_service_account}"
  depends_on = [module.mig_with_https_lb, google_pubsub_topic.app_topic]
}
