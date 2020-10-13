# AWS Security Group Session Killer
A Lambda that gets a list of all Security Groups in a region and filter out all ingress rules that that are flagged with a `temporary_session` string. This is useful when you need to temporarily open a security group to allow debugging an instance or to figure out which IP or ports is being used / using whatever is sitting behind the security group.

If the rule description only contains the `temporary_rule_identifier` then the rule will be removed immediately otherwise it will try to get the vaild till timestamp.

TODO:

Implement NOT functionality, removing any rule that does not have a certain comment on.


fields @timestamp, eventName, eventSource, @message
| filter userIdentity.sessionContext.sessionIssuer.userName	= "paulz-play-paulz-play-sg-session-killer"
| filter eventName not in ["Decrypt", "CreateLogStream"]
| sort @timestamp desc
| limit 20