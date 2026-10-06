#!/usr/bin/env bash
# Sourced by the helper scripts — never run directly. Callers set GROUP_ID.

# notify <title> [message] [terminal-notifier flags...]
# The group makes a repeat replace the previous banner instead of stacking.
# `|| true` so a failing notifier does not abort the caller under `set -e`;
# terminal-notifier exits non-zero when its notification permission is off.
notify() {
  terminal-notifier -title "$1" -message "${2:-}" -group "$GROUP_ID" "${@:3}" \
    >/dev/null 2>&1 || true
}
