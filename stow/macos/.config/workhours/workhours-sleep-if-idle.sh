#!/usr/bin/env bash
set -euo pipefail

# awk reads to the end rather than exiting at the first match: an early exit
# SIGPIPEs ioreg, and pipefail then killed the script (exit 141) before it slept
idle_ns=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ && !v {v=$NF} END {print v}')

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
