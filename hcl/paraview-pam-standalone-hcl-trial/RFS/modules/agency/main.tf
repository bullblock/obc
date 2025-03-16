resource "huaweicloud_identity_agency" "agency" {
  name                   = var.agency_name
  description            = var.agency_description
  delegated_service_name = var.delegated_service_name
  duration               = var.duration

  project_role {
    project = var.region
    roles   = [huaweicloud_identity_role.policy.name]
  }

}


resource "huaweicloud_identity_role" "policy" {
  name        = var.policy_name
  description = var.policy_description
  type        = "AX"
  policy      = var.policy
}