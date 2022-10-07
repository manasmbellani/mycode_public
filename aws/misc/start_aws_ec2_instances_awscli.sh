#!/bin/bash
DELIM="|"
AWS_PROFILE="default"
AWS_REGION="ap-southeast-2"
TAGS_TO_RUN="all"
USAGE="
[-] $0 run [tags_to_run=$TAGS_TO_RUN] [aws_profile=$AWS_PROFILE] [aws_region=$AWS_REGION]

Script will list the EC2 instances and output the instance ID and name with delim: $DELIM
"
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
tags_to_run=${2:-"$TAGS_TO_RUN"}
aws_profile=${3:-"$AWS_PROFILE"}
aws_region=${4:-"$AWS_REGION"}

# Check if jq exists
does_aws_exist=$(which "aws")
if [ -z $does_aws_exist ]; then
    echo "[-] 'aws' does not exist" 1>&2
    exit 1
fi

# Check if jq exists
does_jq_exist=$(which "jq")
if [ -z $does_jq_exist ]; then
    echo "[-] 'jq' does not exist" 1>&2
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
        instance_tags_count=$(($instance_tags_count - 1))

        # Check if we need to start instance
        should_start_instance=0

        # Start the instance if 'all' set
        if [ "$tags_to_run" == "all" ] || [ "$tags_to_run" == "ALL" ]; then
            should_start_instance=1
        else 

            # Get the instance name
            for j in $(seq 0 $instance_tags_count); do
                instance_tag_name=$(echo "$instance_tags" | jq -r ".[$j].Key")
                instance_tag_value=$(echo "$instance_tags" | jq -r ".[$j].Value")

                if [ "$instance_tag_name" == "Name" ] || [ "$instance_tag_name" == "name" ]; then
                    instance_name="$instance_tag_value"
                fi
            done
            
            # Does instance tag value match
            is_tag_matching=$(echo "$tags_to_run" | grep -iE "$instance_tag_value")
            if [ ! -z "$is_tag_matching" ]; then
                should_start_instance=1
            fi
        fi

        # Output the instance ID and name
        if [ "$should_start_instance" == "1" ]; then
            echo "[*] Starting EC2 instance: $instance_id..."
            aws ec2 start-instances --instance-ids "$instance_id" --profile "$aws_profile" --region "$aws_region"
        fi
    fi
done


