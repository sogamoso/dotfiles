#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title YouTube
# @raycast.mode silent
# @raycast.packageName Google

profile_dir=$(ruby -rjson -e '
  data = JSON.parse(File.read("#{Dir.home}/Library/Application Support/Google/Chrome/Local State"))
  dir = data.dig("profile", "info_cache")&.find { |_, v| v["name"] == "Personal" }&.first
  dir ? puts(dir) : exit(1)
') || { echo "Chrome profile '\''Personal'\'' not found"; exit 1; }

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --profile-directory="$profile_dir" \
  --app=https://youtube.com &
disown
