variable "admin_password" {
  type        = string
  description = "The admin password of ECS.The password must be between 8 and 26 characters in length, and it must contain at least three of the following: uppercase letters, lowercase letters, numbers, and special characters (!@$%^-_=+[{}]:,./?)."
  nullable    = true
  sensitive   = true
  validation {
    condition = (
    (length(var.admin_password) >= 8 && length(var.admin_password) <= 26 &&
    length(regexall(".*[a-zA-Z].*", var.admin_password)) > 0 &&
    length(regexall(".*[0-9].*", var.admin_password)) > 0 &&
    #     length(regexall(".*[!@$%^-_=+[{}]:,./?].*", var.admin_password)) > 0
    length(regexall("[!@\\$%\\^\\-_=\\+\\[\\{\\}\\]:,\\./\\?]", var.admin_password)) > 0
    ) || (length(var.admin_password) == 0 || var.admin_password == null))
    error_message = "密码要求长度范围为8到26位，密码至少必须包含大写字母、小写字母、数字和特殊字符（!@$%^-_=+[{}]:,./?）中的三种！"
  }
}

variable "key_pair" {
  type        = string
  description = "Specifies the SSH keypair name used for logging in to the instance.(https://console.huaweicloud.com/dew/)"
  nullable    = true
}

variable "subnet_id" {
  type        = string
  nullable    = false
  description = "Specifies the Id of the subnet.(https://console.huaweicloud.com/vpc/)"
}

variable "charging_mode" {
  type        = string
  nullable    = false
  description = " Specifies the charging mode of the disk. The valid values are as follows:prePaid: the yearly/monthly billing mode,postPaid: the pay-per-use billing mode. Changing this creates a new disk."
  validation {
    condition     = contains(["postPaid", "prePaid"], var.charging_mode)
    error_message = "Allowed values for input_parameter are prePaid or postPaid."
  }
}

variable "period_unit" {
  description = "The period unit of the pre-paid purchase.Valid values are month and year. This parameter is mandatory if charging_mode is set to prePaid. "

  type    = string
  default = "month"
  validation {
    condition     = contains(["month", "year"], var.period_unit)
    error_message = "Allowed values for input_parameter are month or year."
  }
}

variable "period" {
  description = "The period number of the pre-paid purchase. If period_unit is set to month , the value ranges from 1 to 9. If period_unit is set to year, the value ranges from 1 to 3. This parameter is mandatory if charging_mode is set to prePaid. "

  type    = number
  default = 1
}




