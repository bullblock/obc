variable "admin_password" {
  type        = string
  description = "the admin password of ecs."
  nullable    = false
  sensitive   = true
  validation {
    condition = (
    length(var.admin_password) >= 8 && length(var.admin_password) <= 26 &&
    length(regexall(".*[a-zA-Z].*", var.admin_password)) > 0 &&
    length(regexall(".*[0-9].*", var.admin_password)) > 0 &&
    #     length(regexall(".*[!@$%^-_=+[{}]:,./?].*", var.admin_password)) > 0
    length(regexall("[!@\\$%\\^\\-_=\\+\\[\\{\\}\\]:,\\./\\?]", var.admin_password)) > 0
    )
    error_message = "密码要求长度范围为8到26位，密码至少必须包含大写字母、小写字母、数字和特殊字符（!@$%^-_=+[{}]:,./?）中的三种！"
  }
}
variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "Specifies the range of available subnets in the VPC. The value ranges from 10.0.0.0/8 to 10.255.255.0/24, 172.16.0.0/12 to 172.31.255.0/24, or 192.168.0.0/16 to 192.168.255.0/24."
}
variable "vpc_subnet_cidr" {
  type        = string
  default     = "192.168.10.0/24"
  description = "Specifies the network segment on which the subnet resides. The value must be in CIDR format and within the CIDR block of the VPC. The subnet mask cannot be greater than 28. Changing this creates a new Subnet."
}
variable "vpc_subnet_gateway_ip" {
  type        = string
  default     = "192.168.10.1"
  description = "Specifies the gateway of the subnet. The value must be a valid IP address in the subnet segment. Changing this creates a new subnet."
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

# variable "policy" {
#   type        = string
#   nullable = false
#   description = "Specifies the content of the custom policy in JSON format. For more details, please refer to the official document."
# }
