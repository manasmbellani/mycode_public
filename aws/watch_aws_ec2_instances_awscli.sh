#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
DELIM="|"
AWS_PROFILE="default"
AWS_REGION="ap-southeast-2"
REPEAT_PERIOD=5
SEPARATOR="----------"
USAGE="
[-] $0 run [aws_profile=$AWS_PROFILE] [aws_region=$AWS_REGION] [repeat_period=$REPEAT_PERIOD]

Script will repeatedly list the EC2 instances and output the instance ID and name with 
delim: $DELIM using awscli every $REPEAT_PERIOD (by default)
" 
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
aws_profile=${2:-"$AWS_PROFILE"}
aws_region=${3:-"$AWS_REGION"}
repeat_period=${4:-"$REPEAT_PERIOD"}

# Check if jq exists
does_jq_exist=$(which "jq")
if [ -z $does_jq_exist ]; then
    echo "[-] 'JQ' does not exist" 1>&2
    exit 1
fi

while [ "1" == "1" ]; do
    
    "$SCRIPT_DIR/list_aws_ec2_instances_awscli.sh" run "$aws_profile" "$aws_region"

    # Print separator Sleep for some time before next iteration
    echo "$SEPARATOR"
    sleep "$repeat_period"
done

