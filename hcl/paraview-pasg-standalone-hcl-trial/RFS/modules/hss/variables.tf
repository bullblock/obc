variable "host_id" {
  description = "Specifies the host ID for the host protection. Changing this parameter will create a new resource."
  type        = string
  default     = null
}

variable "host_protection_version" {
  description = "Specifies the protection version enabled by the host.The valid values are as follows:hss.version.basic: Basic version.hss.version.advanced: Professional version.hss.version.enterprise: Enterprise version.hss.version.premium: Ultimate version."
  type        = string
  default     = null
}

variable "quota_version" {
  description = "Specifies protection quota version. Changing this parameter will create a new resource.The valid values are as follows:hss.version.basic: Basic version.hss.version.advanced: Professional version.hss.version.enterprise: Enterprise version.hss.version.premium: Ultimate version.hss.version.wtp: Web page tamper prevention version.hss.version.container.enterprise: Container version."
  type        = string
  default     = null
}

variable "quota_tags" {
  description = "Specifies the key/value pairs to associate with the HSS quota."
  type        = map(string)
  default     = { Purpose = "MkpApplication" }
}

variable "charging_mode" {
  type        = string
  default     = "prePaid"
  description = "Specifies the charging mode of the CBH instance. The options are as follows:prePaid: the yearly/monthly billing mode"
}

variable "period_unit" {
  description = "Specifies the charging period unit of the instance. Valid values are month and year."

  type    = string
  default = "month"
}

variable "period" {
  description = "Specifies the charging period of the CBH instance. If period_unit is set to month, the value ranges from 1 to 9. If period_unit is set to year, the value ranges from 1 to 3."

  type    = number
  default = 1
}

variable "is_wait_host_available" {
  description = "Specifies whether to wait for the host agent status to become online. The value can be true or false. Defaults to false."

  type = bool
  default = false
}

variable "enterprise_project_id" {
  description = "Specifies the enterprise project ID to which the CBH instance belongs. For enterprise users, if omitted, default enterprise project will be used."

  type    = string
  default = null
}
