locals {
  naming = {
    "role"       = "${var.naming_prefix}-sg-session-killer"
    "policy"     = "${var.naming_prefix}-sg-session-killer"
    "lambda"     = "${var.naming_prefix}-sg-session-killer"
    "event_rule" = "${var.naming_prefix}-sg-session-killer"
  }
}