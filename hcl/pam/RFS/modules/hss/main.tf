resource "huaweicloud_hss_host_protection" "host_protection" {
  host_id       = var.host_id
  version       = var.host_protection_version
  charging_mode = var.charging_mode

  quota_id = var.charging_mode == "prePaid" ? huaweicloud_hss_quota.quota[0].id : null

  is_wait_host_available = var.is_wait_host_available

  enterprise_project_id = var.enterprise_project_id
}

resource "huaweicloud_hss_quota" "quota" {
  count       = var.charging_mode == "prePaid" ? 1 : 0
  version     = var.quota_version
  period_unit = var.period_unit
  period      = var.period

  tags                  = var.quota_tags
  enterprise_project_id = var.enterprise_project_id
}