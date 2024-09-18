#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# Variables (can be passed in or set here)
APP_NAME=test_tmp_tags_and_capacity_provider

TASK_TEMPLATE_FAMILY=${TASK_TEMPLATE_FAMILY:-"${APP_NAME}_template"}
APP_TASK_FAMILY=${APP_TASK_FAMILY:-"${APP_NAME}"}
CONTAINER_NAME=${CONTAINER_NAME:-"main"}
IMAGE_REPOSITORY="ghcr.io/supermanadam007/nginx-test"
IMAGE_TAG=v0.0.2
APP_VERSION=v0.0.2
CLUSTER_NAME=$APP_NAME
SERVICE_NAME=$APP_NAME
FORCE_DEPLOY=${FORCE_DEPLOY:-false}  # Option to manually trigger the ECS service update

# Ensure required environment variables are set
if [[ -z "$IMAGE_REPOSITORY" || -z "$IMAGE_TAG" || -z "$APP_VERSION" ]]; then
  echo "Error: IMAGE_REPOSITORY, IMAGE_TAG, and APP_VERSION must be set."
  exit 1
fi

# Fetch the latest task definition template from AWS ECS
echo "Fetching the latest task definition template..."
TEMPLATE_TASK_DEF=$(aws ecs describe-task-definition --task-definition ${TASK_TEMPLATE_FAMILY} --query 'taskDefinition' --output json)

# Check if the task definition template was retrieved successfully
if [[ -z "$TEMPLATE_TASK_DEF" ]]; then
  echo "Error: Failed to fetch the task definition template."
  exit 1
fi

# Remove unwanted fields from the task definition
echo "Cleaning up the task definition..."
CLEANED_TASK_DEF=$(echo "$TEMPLATE_TASK_DEF" | \
  jq 'del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy, .cpu, .memory)')

# Update the task definition with the new family, image, and environment variables
echo "Customizing task definition..."
NEW_TASK_DEF=$(echo "$CLEANED_TASK_DEF" | \
  jq '.family = "'${APP_TASK_FAMILY}'"' | \
  jq '.containerDefinitions[] |= if .name == "'${CONTAINER_NAME}'" then .image = "'${IMAGE_REPOSITORY}:${IMAGE_TAG}'" else . end' | \
  jq '.containerDefinitions[] |= if .name == "'${CONTAINER_NAME}'" then .environment += [{"name": "APP_VERSION", "value": "'${APP_VERSION}'"}] else . end')

# Check if jq successfully modified the task definition
if [[ -z "$NEW_TASK_DEF" ]]; then
  echo "Error: Failed to customize the task definition."
  exit 1
fi

# Register the new task definition in ECS
echo "Registering the new task definition..."
NEW_TASK_DEF_ARN=$(aws ecs register-task-definition --cli-input-json "$NEW_TASK_DEF" --query 'taskDefinition.taskDefinitionArn' --output text)

# Check if the task definition was registered successfully
if [[ -z "$NEW_TASK_DEF_ARN" ]]; then
  echo "Error: Failed to register the new task definition."
  exit 1
fi

# Output success message with task definition ARN
echo "Task definition for ${APP_TASK_FAMILY} registered successfully with ARN: ${NEW_TASK_DEF_ARN}"

# # Fetch all task definition revisions for the task family
# echo "Fetching all task definition revisions..."
# ALL_TASK_DEF_ARNS=$(aws ecs list-task-definitions --family-prefix "$APP_TASK_FAMILY" --query 'taskDefinitionArns' --output json)

# # Deregister all task definition revisions except the new one
# echo "Deregistering old task definition revisions..."
# for task_def_arn in $(echo "$ALL_TASK_DEF_ARNS" | jq -r '.[]'); do
#   if [[ "$task_def_arn" != "$NEW_TASK_DEF_ARN" ]]; then
#     echo "Deregistering old task definition: $task_def_arn"
#     aws ecs deregister-task-definition --task-definition "$task_def_arn" > /dev/null
#   else
#     echo "Skipping deregistration for the new task definition: $task_def_arn"
#   fi
# done
# 
# echo "All old task definitions deregistered."


# Manual step: Check if FORCE_DEPLOY is set to true and force an update
if [[ "$FORCE_DEPLOY" == "true" ]]; then
  echo "Forcing ECS service deployment with the new task definition..."
  aws ecs update-service --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME" --force-new-deployment --task-definition "$NEW_TASK_DEF_ARN" --output text
  echo "ECS service updated and deployment forced."
else
  echo "Skipping ECS service update. Run the following command to manually deploy:"
  echo "aws ecs update-service --cluster \"$CLUSTER_NAME\" --service \"$SERVICE_NAME\" --force-new-deployment --task-definition \"$NEW_TASK_DEF_ARN\" --output text"
fi
