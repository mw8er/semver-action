#!/usr/bin/env bash
set -ueo pipefail

# Parse command-line arguments
if [[ $# -gt 1 ]]; then
  >&2 echo "Usage: $0 [<prefix: v or V>]"
  exit 1
fi

prefix=""
if [[ $# -eq 1 ]]; then
  prefix=$1
  if [[ ! "$prefix" =~ [vV] ]] || [[ ${#prefix} -gt 1 ]]; then
    >&2 echo "Prefix must be v or V"
    exit 1
  fi
fi

# Default version
version="${prefix}0.0.0"

# Get the latest git tag
if [[ ! -z $(git tag) ]]; then
  version=$(git describe --tags --abbrev=0 2>/dev/null)
fi

echo "$version"