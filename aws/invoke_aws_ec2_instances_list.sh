#!/bin/bash
DELIM="|"
AWS_PROFILE="default"
AWS_REGION="ap-southeast-2"
USAGE="
[-] $0 run [aws_profile=$AWS_PROFILE] [aws_region=$AWS_REGION]

Script will list the EC2 instances and output the instance ID and name with 
delim: $DELIM
"
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
aws_profile=${2:-"$AWS_PROFILE"}
aws_region=${3:-"$AWS_REGION"}

# Check if jq exists
does_jq_exist=$(which "jq")
if [ -z $does_jq_exist ]; then
    echo "[-] 'JQ' does not exist" 1>&2
    exit 1
fi

# Get the instance config and instance count
instances_out=$(aws ec2 describe-instances --profile="$aws_profile" --region="$aws_region")
instances_count=$(echo "$instances_out" | jq -r ".Reservations | length")

# For each instance
for i in $(seq 0 $instances_count); do
    # Get instance ID
    instance_id=$(echo "$instances_out" | jq -r ".Reservations[$i].Instances[0].InstanceId")

    # Get the instance tags 
    if [ ! -z "$instance_id" ] && [ "$instance_id" != "null" ]; then
        instance_tags=$(echo "$instances_out" | jq -r ".Reservations[$i].Instances[0].Tags")
        instance_tags_count=$(echo "$instances_out" | jq -r ".Reservations[$i].Instances[0].Tags | length")

        # Get the instance name
        for j in $(seq 0 $instance_tags_count); do
            instance_tag_name=$(echo "$instance_tags" | jq -r ".[$j].Key")
            instance_tag_value=$(echo "$instance_tags" | jq -r ".[$j].Value")

            if [ "$instance_tag_name" == "Name" ] || [ "$instance_tag_name" == "name" ]; then
                instance_name="$instance_tag_value"
            fi
        done
        # Output the instance ID and name
        echo "$instance_id$DELIM$instance_name"
    fi
done


