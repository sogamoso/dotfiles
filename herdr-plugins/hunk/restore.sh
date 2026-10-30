#!/usr/bin/env bash
# The startup hook: after a herdr server restart, start hunk again in every
# pane it was running in when the server stopped. herdr brings each pane back
# as a fresh shell in its saved directory and resumes the agents through their
# integrations, nothing else, so the diff of every review layout came back as
# an empty pane. The hunk function in the shells' alias files keeps a marker
# named after its pane in the state directory while hunk runs, holding the
# command line, and removes it when hunk exits. A server restart takes hunk and
# its shell down together, so the marker outlives them and is found here.
#
# Only a pane that still exists and is back at an idle shell gets the command
# typed in. A pane that is gone drops its marker; one busy with something else,
# hunk included after a live handoff, is left alone. No errexit: a pane that
# can't be read shouldn't stop the others.
set -uo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"
dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/hunk-panes"

[[ -d $dir ]] || exit 0

# Usage: restore <pane_id> <command>
restore() {
  local pane="$1" command="$2" info tries

  if ! "$herdr" pane get "$pane" >/dev/null 2>&1; then
    rm -f "${dir:?}/${pane:?}"
    echo "$pane is gone, marker dropped"
    return
  fi

  # The shells start with the server; give each up to 30 seconds to reach its prompt
  for (( tries = 0; tries < 60; tries++ )); do
    if info=$("$herdr" pane process-info --pane "$pane" 2>/dev/null); then
      if jq -e 'any(.result.process_info.foreground_processes[]; .name == "hunk")' <<<"$info" >/dev/null; then
        echo "$pane already runs hunk"
        return
      fi
      if jq -e '.result.process_info
        | (.foreground_processes | length) == 1 and .foreground_processes[0].pid == .shell_pid' <<<"$info" >/dev/null; then
        # At its prompt by process, though the shell may still be reading its startup files
        sleep 1
        "$herdr" pane run "$pane" "$command" >/dev/null && echo "$pane: $command"
        return
      fi
    fi
    sleep 0.5
  done
  echo "$pane didn't reach a prompt in 30 seconds, left alone"
}

for marker in "$dir"/*; do
  [[ -f $marker ]] || continue
  IFS= read -r command <"$marker" || true
  [[ -n $command ]] || continue
  restore "$(basename "$marker")" "$command" &
done
wait
