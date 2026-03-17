#!/usr/bin/env bash
set -euo pipefail

idle_ns=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print $NF; exit}')

if [[ -z "$idle_ns" ]]; then
  echo "Could not read HIDIdleTime — skipping sleep"
  exit 0
fi

idle_sec=$(( idle_ns / 1000000000 ))

if (( idle_sec >= 600 )); then
  echo "Idle for ${idle_sec}s — sleeping system"
  pmset sleepnow
else
  echo "Idle for ${idle_sec}s — not idle enough, skipping sleep"
fi
