const AWS = require('aws-sdk');
const util = require('util')

// AWS.config.update({region: 'eu-west-1'});

const ec2 = new AWS.EC2({apiVersion: '2016-11-15'});
const describeSecurityGroupsPromise = util.promisify(ec2.describeSecurityGroups.bind(ec2));
const revokeSecurityGroupIngressPromise = util.promisify(ec2.revokeSecurityGroupIngress.bind(ec2));

const temporary_rule_identifier = "temporary_session"

function handler(event, context, callback){
    
    const params = {
        DryRun: false
    };

    describeSecurityGroupsPromise(params)
    .then(data => {
        const securityGroupsIpPermissions = data.SecurityGroups.reduce((SecurityGroupsAcc, SecurityGroup)=>{ 
            const GroupId = SecurityGroup.GroupId;
            
            const ipPermissions = SecurityGroup.IpPermissions.reduce((IpPermissionsAcc, IpPermission) => {

                const temporaryRuleIpRanges = IpPermission.IpRanges.filter(IpRange => {
                    if(!IpRange.Description) {
                        return false;
                    } else {
                        return IpRange.Description.includes(temporary_rule_identifier);
                    }
                });

                const temporaryRuleIpv6Ranges = IpPermission.Ipv6Ranges.filter(Ipv6Range => {
                    if(!Ipv6Range.Description) {
                        return false;
                    } else {
                        return Ipv6Range.Description.includes(temporary_rule_identifier);
                    }
                });

                const temporaryRulePrefixListIds = IpPermission.PrefixListIds.filter(PrefixListId => {
                    if(!PrefixListId.Description) {
                        return false;
                    } else {
                        return PrefixListId.Description.includes(temporary_rule_identifier);
                    }
                });

                const IpRangesToKill = temporaryRuleIpRanges.map(IpRange => {
                    return {
                        GroupId,
                        IpPermissions: [
                            {
                                FromPort: IpPermission.FromPort,
                                ToPort: IpPermission.ToPort,
                                IpProtocol: IpPermission.IpProtocol,
                                IpRanges: [IpRange]
                            }
                        ]
                    };
                });

                const Ipv6RangesToKill = temporaryRuleIpv6Ranges.map(Ipv6Range => {
                    return {
                        GroupId,
                        IpPermissions: [
                            {
                                FromPort: IpPermission.FromPort,
                                ToPort: IpPermission.ToPort,
                                IpProtocol: IpPermission.IpProtocol,
                                Ipv6Ranges: [Ipv6Range]
                            }
                        ]
                    };
                });

                const PrefixListIdsToKill = temporaryRulePrefixListIds.map(PrefixListId => {
                    return {
                        GroupId,
                        IpPermissions: [
                            {
                                FromPort: IpPermission.FromPort,
                                ToPort: IpPermission.ToPort,
                                IpProtocol: IpPermission.IpProtocol,
                                PrefixListIds: [PrefixListId]
                            }
                        ]
                    };
                });

                return IpPermissionsAcc.concat(IpRangesToKill, Ipv6RangesToKill, PrefixListIdsToKill);

            }, []);
           
            return SecurityGroupsAcc.concat(ipPermissions);

       }, []);


       console.log(`Found ${securityGroupsIpPermissions.length} temporary rules\n`, JSON.stringify(securityGroupsIpPermissions));

       const revokeAllTemporaryPromiseList = securityGroupsIpPermissions.map(securityGroupsIpPermission => revokeSecurityGroupIngressPromise(securityGroupsIpPermission));

       return Promise.all(revokeAllTemporaryPromiseList);

    })
    .then(data => {
        console.log(data);
    })
    .catch(error =>{
        console.log("ERROR", error);
        callback(error);
    });

};

exports.handler = handler;
