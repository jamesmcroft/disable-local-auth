#!/bin/bash

# Variables
disableLocalAuth="true"
apiVersion="2023-12-15-preview"

# Get all event grid topics
echo "Getting all event grid topics..."
ids=$(az eventgrid topic list --query '[].id' --output tsv)

# Loop through each event grid topic
for id in $ids; do
  
  # Get the name of the event grid topic
  name=$(echo $id | awk -F '/' '{print $9}')

  if [ "$disableLocalAuth" = "true" ]; then
    echo "Disabling local authentication for event grid topic [$name]..."
  else
    echo "Enabling local authentication for event grid topic [$name]..."
  fi

  # Disable or enable local authentication
  az rest --method patch \
    --url "https://management.azure.com${id}?api-version=$apiVersion" \
    --headers "Content-Type=application/json" \
    --body "{\"properties\": {\"disableLocalAuth\": $disableLocalAuth}}" 1> /dev/null
  
  if [ $? -eq 0 ]; then
    if [ "$disableLocalAuth" = "true" ]; then
      echo "Successfully disabled local authentication for event grid topic [$name]"
    else
      echo "Successfully enabled local authentication for event grid topic [$name]"
    fi
  else
    if [ "$disableLocalAuth" = "true" ]; then
      echo "Failed to disable local authentication for event grid topic [$name]"
    else
      echo "Failed to enable local authentication for event grid topic [$name]"
    fi
    exit -1
  fi
done