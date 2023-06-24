#!/bin/bash

# Create the result/in directory if it doesn't exist
mkdir -p result/in

# Create three test folders
for i in {1..3}; do
  folder_name="test_folder_$i"
  folder_path="result/in/$folder_name"
  
  mkdir -p "$folder_path"
  echo "Created $folder_path"
done

echo "Test folders created successfully."
