#!/bin/bash
set -ueo pipefail

# Define the git branch to be analyzed
branch_name="main"

# Get the latest git tag on the branch
latest_tag="origin/$branch_name"
if [[ ! -z $(git tag) ]]; then
  latest_tag=$(git describe --abbrev=0 --tags $branch_name)
fi

# Get the commit messages since the latest tag
commit_messages=$(git log $latest_tag..HEAD --pretty=format:"%s")

# Initialize version increment variables
major=0
minor=0
patch=0

# Loop through commit messages and determine version increment
while read -r commit_message; do
  case $commit_message in
    *'BREAKING CHANGE:'*|*'feat!:'*|*'BREAKING CHANGE('*'):'*|*'feat('*')!:'*)
      # Increment major version for incompatible API changes
      major=1
      ;;
    *'feat:'*|*'feat('*'):'*)
      # Increment minor version for backward-compatible new features
      minor=1
      ;;
    *'fix:'*|*'fix('*'):'*)
      # Increment patch version for backward-compatible bug fixes
      patch=1
      ;;
    *)
      # Ignore other commit messages
      ;;
  esac
done <<< "$commit_messages"

# Print the determined version increment
if [[ $major -eq 1 ]]; then
  echo 0
elif [[ $minor -eq 1 ]]; then
  echo 1
elif [[ $patch -eq 1 ]]; then
  echo 2
else
  >&2 echo "Error: Missing infos about semantic versioning in commit messages"
  exit 1
fi
