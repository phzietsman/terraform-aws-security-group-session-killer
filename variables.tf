variable naming_prefix {
  type        = string
  description = "All reousrce names will be prefixed with this name"
}

variable tags {
  type        = map(string)
  description = "Tags to add to all resources"
  default = {}
}

variable temporary_rule_identifier {
  type        = string
  description = "Will search all security group rule descriptions for this string"
  default     = "temporary_session"
}

variable temporary_rule_decription_delimiter {
  type        = string
  description = "Will search all security group rule descriptions for this string"
  default     = "|"
}