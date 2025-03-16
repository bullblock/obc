variable "agency_name" {
  type        = string
  default     = "auto_deploy_agency"
  description = " (Required, String, ForceNew) Specifies the name of agency. The name is a string of 1 to 64 characters. Changing this will create a new agency."
}

variable "agency_description" {
  type        = string
  default     = "auto_deploy_agency"
  description = "Specifies the supplementary information about the agency. The value is a string of 0 to 255 characters, excluding these characters: '@#$%^&*<>\\'."
}

variable "delegated_service_name" {
  type        = string
  default     = "op_svc_ecs"
  description = "Specifies the name of delegated service"
}

variable "duration" {
  type        = number
  default     = 1
  description = " (Optional, String) Specifies the validity period of an agency. The valid value are FOREVER, ONEDAY or the specific days, for example, '20'. The default value is FOREVER."
}


variable "policy_name" {
  type        = string
  default     = "auto_deploy_policy"
  description = "Specifies the name of the custom policy."
}

variable "policy_description" {
  type        = string
  default     = "auto_deploy_policy"
  description = "Specifies the description of the custom policy."
}

variable "policy" {
  type        = string
  description = "Specifies the content of the custom policy in JSON format. For more details, please refer to the official document."
}

variable "region" {
  type        = string
  description = "Specifies the name of project."
}