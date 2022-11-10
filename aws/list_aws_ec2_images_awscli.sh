#!/bin/bash
DELIM="|"
AWS_PROFILE="default"
AWS_REGION="ap-southeast-2"
USAGE="
[-] $0 run [aws_profile=$AWS_PROFILE] [aws_region=$AWS_REGION]

Script will list the AWS EC2 images, and output with delim: $DELIM via awscli
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
images_out=$(aws ec2 describe-images --owners self --profile="$aws_profile" --region="$aws_region" | jq -r ".[]")
images_count=$(echo "$images_out" | jq -r ". | length")

# For each instance
for i in $(seq 0 $images_count); do
    # Get image
    image_id=$(echo "$images_out" | jq -r ".[$i].ImageId")

    # Get the image ID
    if [ ! -z "$image_id" ] && [ "$image_id" != "null" ]; then
        
        # Get the image tags 
        image_tags=$(echo "$images_out" | jq -r ".[$i].Tags")
        image_tags_count=$(echo "$instances_out" | jq -r ".[$i].Tags | length")
        
        # Get the image name
        for j in $(seq 0 $image_tags_count); do
            image_tag_name=$(echo "$image_tags" | jq -r ".[$j].Key")
            image_tag_value=$(echo "$image_tags" | jq -r ".[$j].Value")

            if [ "$image_tag_name" == "Name" ] || [ "$image_tag_name" == "name" ]; then
                image_name="$image_tag_value"
            fi
        done

        # Get the image creation date
        image_creation_date=$(echo "$images_out" | jq -r ".[$i].CreationDate")

        # Get the platform details for the image
        image_platform_details=$(echo "$images_out" | jq -r ".[$i].PlatformDetails")

        # Output the image info
        echo "$image_id$DELIM$image_name$DELIM$image_creation_date$DELIM$image_platform_details"
    fi
done
