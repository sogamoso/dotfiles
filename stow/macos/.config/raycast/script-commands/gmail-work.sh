#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Gmail Work
# @raycast.mode silent
# @raycast.packageName Gmail

profile_dir=$(ruby -rjson -e '
  data = JSON.parse(File.read("#{Dir.home}/Library/Application Support/Google/Chrome/Local State"))
  dir = data.dig("profile", "info_cache")&.find { |_, v| v["name"] == "Work" }&.first
  dir ? puts(dir) : exit(1)
') || { echo "Chrome profile 'Work' not found"; exit 1; }

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --profile-directory="$profile_dir" \
  --app=https://mail.google.com &
disown
