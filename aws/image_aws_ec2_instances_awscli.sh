#!/bin/bash
DRY_RUN="0"
DELIM="|"
AWS_PROFILE="default"
AWS_REGION="ap-southeast-2"
USAGE="
[-] $0 <tags_to_image> [dry_run=$DRY_RUN] [aws_profile=$AWS_PROFILE] [aws_region=$AWS_REGION] 

Script will image the EC2 instances with specified tags.
If 'all' set, then all instances irrespective of image get tagged
Otherwise, if specific tag value specified then the particular instance(s) with that tag get imaged

If dry_run set to 1, then the image does not get created and any instances are not deleted
"
if [ $# -lt 1 ]; then
    echo "$USAGE"
    exit 1
fi
tags_to_image="${1}"
dry_run="${2}"
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

# Getting current datetime
current_datetime=$(date +%Y%m%d-%H%M)

# For each instance
for i in $(seq 0 $instances_count); do
    # Get instance ID
    instance_id=$(echo "$instances_out" | jq -r ".Reservations[$i].Instances[0].InstanceId")

    # Get the instance tags 
    if [ ! -z "$instance_id" ] && [ "$instance_id" != "null" ]; then
        instance_tags=$(echo "$instances_out" | jq -r ".Reservations[$i].Instances[0].Tags")
        instance_tags_count=$(echo "$instances_out" | jq -r ".Reservations[$i].Instances[0].Tags | length")
        instance_tags_count=$(($instance_tags_count - 1))

        # Check if we need to image instance
        should_image_instance=0

        # Start the instance if 'all' set
        if [ "$tags_to_image" == "all" ] || [ "$tags_to_image" == "ALL" ]; then
            should_image_instance=1
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
            is_tag_matching=$(echo "$tags_to_image" | grep -iE "$instance_tag_value")
            if [ ! -z "$is_tag_matching" ]; then
                should_image_instance=1
            fi
        fi

        # Image instance
        if [ "$should_image_instance" == "1" ]; then
            echo "[*] Imaging EC2 instance: $instance_id with name: $instance_name..."
            image_name="$image_name-$current_datetime"
            if [ "$dry_run" == "1" ]; then
                aws ec2 create-image --name "$instance_name-$current_datetime" \
                    --description "$instance_name-$current_datetime" \
                    --instance-id "$instance_id" \
                    --tag-specifications "ResourceType=image,Tags=[{Key=Name,Value=$image_name}]" \
                    --dry-run
            else
                aws ec2 create-image --name "$instance_name-$current_datetime" \
                    --description "$instance_name-$current_datetime" \
                    --instance-id "$instance_id" \
                    --tag-specifications "ResourceType=image,Tags=[{Key=Name,Value=$image_name}]"
            fi
        fi
        
        # List images 
        

        # Clear older snapshots with same image name
        
    fi
done

