#!/bin/bash
set -ueo pipefail

# Function to check if a string is a valid integer
is_integer() {
  [[ $1 =~ ^[0-9]+$ ]]
}

# Function to compare two version numbers
# Returns 0 if equal, 1 if greater, -1 if smaller
compare_versions() {
  local v1=(${1//./ })
  local v2=(${2//./ })

  for ((i=0; i<${#v1[@]}; i++)); do
    if ! is_integer "${v1[$i]}" || ! is_integer "${v2[$i]}"; then
      >&2 echo "Error: Invalid version number"
      exit 1
    fi

    if [[ "${v1[$i]}" -lt "${v2[$i]}" ]]; then
      echo "-1"
      return
    elif [[ "${v1[$i]}" -gt "${v2[$i]}" ]]; then
      echo "1"
      return
    fi
  done

  echo "0"
}

# Function to increment a version number
increment_version() {
  local version=(${1//./ })
  local position=$2

  if ! is_integer "${version[$position]}"; then
    >&2 echo "Error: Invalid version number"
    exit 1
  fi

  version[$position]=$((version[$position] + 1))

  for ((i=position+1; i<${#version[@]}; i++)); do
    version[$i]=0
  done

  echo "${version[*]}"
}

# Main script

# Parse command-line arguments
if [[ $# -ne 2 ]]; then
  >&2 echo "Usage: $0 <current_version> <increment_position>"
  exit 1
fi

current_version="$1"
increment_position="$2"

# Check if current_version is a valid version number with optional build and pre-release
if ! [[ "$current_version" =~ ^[vV]?[0-9]+\.[0-9]+\.[0-9]+(\-[a-zA-Z0-9\.]+)?(\+[a-zA-Z0-9\.]+)?$ ]]; then
  >&2 echo "Error: Invalid current version number"
  exit 1
fi

# Determine the prefix from the current_version
prefix="${current_version:0:1}"
if is_integer $prefix
then
  prefix=""
fi

# If the prefix is 'v' or 'V', remove it from the current_version for comparison and incrementing
if [[ "$prefix" =~ [vV] ]]; then
  current_version="${current_version:1}"
fi

# Check if increment_position is a valid integer
if ! is_integer "$increment_position" || [[ $increment_position -lt 0 ]] || [[ $increment_position -gt 2 ]]; then
  >&2 echo "Error: Invalid increment position"
  exit 1
fi

# Increment the version number and store the result in new_version_without_prefix
new_version=$(increment_version "$current_version" "$increment_position")
new_dotted_version=(${new_version// /.})
major=$(echo "$new_version" | cut -d ' ' -f 1)
minor=$(echo "$new_version" | cut -d ' ' -f 2)
patch=$(echo "$new_version" | cut -d ' ' -f 3)

# Create a JSON object with the results
echo "{\"version\": \"$prefix$new_dotted_version\", \"major\": \"$major\", \"minor\": \"$minor\", \"patch\": \"$patch\", \"prefix\": \"$prefix\"}"