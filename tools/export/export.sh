#!/bin/bash

# Default values
import_dir=${IMPORT_DIR:-default_import_dir}
export_url=${EXPORT_URL:-default_export_url}
export_token=${EXPORT_TOKEN:-default_export_token}
java_class=${JAVA_CLASS:-"com.example.Export"}
java_home=${JAVA_HOME:-"/usr/lib/jvm/java-11-openjdk"}

# Parse named parameters
while [[ $# -gt 0 ]]; do
    case "$1" in
        --import-dir)
            import_dir="$2"
            shift 2
            ;;
        --export-url)
            export_url="$2"
            shift 2
            ;;
        --export-token)
            export_token="$2"
            shift 2
            ;;
        --java-class)
            java_class="$2"
            shift 2
            ;;
        --java-home)
            java_home="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

# Get the timestamp and host name
timestamp=$(date +%s%3N)
host_name=$(hostname)

# Generate the InfluxDB line protocol
line_protocol="export,status=start,host=$host_name import_dir=\"$import_dir\" $timestamp"

# Set the output file path
output_dir="result/out"
output_file="$output_dir/export.txt"
echo $line_protocol > $output_file

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Execute Java with memory allocation and append output to the file
"$java_home/bin/java" -Xmx3g \
    -Dimport_dir="$import_dir" \
    -Dexport_url="$export_url" \
    -Dexport_token="$export_token" \
    -cp ../../build/libs/export-1.0-SNAPSHOT.jar \
    "$java_class" "$@" >> "$output_file"

timestamp=$(date +%s%3N)
line_protocol="export,status=complete,host=$host_name import_dir=\"$import_dir\" $timestamp"
echo $line_protocol >> $output_file

# Send the line protocol to InfluxDB
curl -i -XPOST "$export_url" \
    --header "Authorization: Token $export_token" \
    --data-binary @"$output_file"

echo "Configuration exported to $output_file"
