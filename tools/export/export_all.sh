#!/bin/bash

# Default value for PARENT_DIR_TO_IMPORT
default_parent_dir_to_import="default_parent_dir"
parent_dir_to_import=${PARENT_DIR_TO_IMPORT:-$default_parent_dir_to_import}

# Check if PARENT_DIR_TO_IMPORT is provided as a named parameter or environment variable
if [ "$parent_dir_to_import" = "$default_parent_dir_to_import" ]; then
    echo "Using default PARENT_DIR_TO_IMPORT: $parent_dir_to_import"
else
    echo "Using custom PARENT_DIR_TO_IMPORT: $parent_dir_to_import"
fi

# Check if PARENT_DIR_TO_IMPORT exists
if [ ! -d "$parent_dir_to_import" ]; then
    echo "Error: $parent_dir_to_import does not exist."
    exit 1
fi

# Array to store subfolders and background process IDs
subfolders=()
pids=()

# Iterate through subfolders in PARENT_DIR_TO_IMPORT
for subfolder in "$parent_dir_to_import"/*/; do
  subfolder=${subfolder%*/}  # Remove trailing slash
  subfolders+=("$subfolder") # Store the subfolder name

  echo "Processing subfolder: $subfolder"

  # Run export.sh in a separate thread for each subfolder
  "./export.sh" --import-dir "$subfolder" &
  pids+=($!)  # Store the process ID of the background thread
done

# Wait for all threads to complete
total_subfolders=${#subfolders[@]} # Total number of subfolders
completed_subfolders=0

for pid in "${pids[@]}"; do
  wait "$pid"
  ((completed_subfolders++))
  echo "Subfolder process completed: $completed_subfolders/$total_subfolders"
done

echo "Export completed for all subfolders."
