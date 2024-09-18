#!/usr/bin/env bash

# Exit immediately if any command fails
set -e

# Variables (can be passed in or set here)
TASK_TEMPLATE_FAMILY=${TASK_TEMPLATE_FAMILY:-"test_tmp_tags_and_capacity_provider_template"}
NEW_TASK_FAMILY=${NEW_TASK_FAMILY:-"test_tmp_tags_and_capacity_provider"}
CONTAINER_NAME=${CONTAINER_NAME:-"main"}
IMAGE_REPOSITORY="ghcr.io/supermanadam007/nginx-test"
IMAGE_TAG=v0.0.1
APP_VERSION=v0.0.1

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

# Update the task definition with the new family, image, and environment variables
echo "Customizing task definition..."
NEW_TASK_DEF=$(echo "$TEMPLATE_TASK_DEF" | \
  jq '.family = "'${NEW_TASK_FAMILY}'"' | \
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
echo "Task definition for ${NEW_TASK_FAMILY} registered successfully with ARN: ${NEW_TASK_DEF_ARN}"
