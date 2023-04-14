#!/bin/bash
set -ueo pipefail

# Parse command-line arguments
if [[ $# -gt 2 ]]; then
  echo "Usage: $0 [<prefix: v or V>]"
  exit 1
fi

branch_name=$1

prefix=""
if [[ $# -eq 2 ]]; then
  prefix=$2
fi

currentVersion=$(./currentVersion.sh $prefix)
increasePosition=$(./increasePosition.sh $branch_name)
nextVersion=$(./nextVersion.sh $currentVersion $increasePosition)

echo "currentVersion = $currentVersion"
echo "increasePosition = $increasePosition"
echo "nextVersion = $nextVersion"

echo "next-version=$(echo $nextVersion | jq -r '.version')" >> $GITHUB_OUTPUT
echo "next-major=$(echo $nextVersion | jq -r '.major')" >> $GITHUB_OUTPUT
echo "next-minor=$(echo $nextVersion | jq -r '.minor')" >> $GITHUB_OUTPUT
echo "next-patch=$(echo $nextVersion | jq -r '.patch')" >> $GITHUB_OUTPUT
