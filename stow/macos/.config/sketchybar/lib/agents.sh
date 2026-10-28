#!/usr/bin/env bash
# Sourced by plugins/agents.sh — never run directly.
#
# One fetcher per agent, each printing the same record so the bar never deals
# with a provider's own format:
#   {"plan": "...", "status": "...", "limits": [{"label", "percent", "resets"}]}
# resets is epoch seconds. status is empty when the numbers are current, and
# says why otherwise. A fetcher prints nothing when the agent isn't set up here.

# Rate limits come from Anthropic's OAuth usage endpoint, the one Omarchy's
# agents panel reads, called with Claude Code's own login. The token goes from
# the keychain to curl through pipes only: never a variable, a file, a
# here-string (bash 3.2 writes those to disk) or a command line, and only ever
# to api.anthropic.com. The endpoint is undocumented and rate-limits readily.
agents_claude() {
  local plan response code
  security find-generic-password -s "Claude Code-credentials" >/dev/null 2>&1 || return 0

  plan=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null | jq -r '
    .claudeAiOauth as $o
    | ($o.subscriptionType // "" | ascii_downcase) as $sub
    | ($o.rateLimitTier // "" | capture("max_(?<m>[0-9]+x)")?.m // "") as $max
    | [($sub | if . == "" then empty else (.[:1] | ascii_upcase) + .[1:] end),
       (if $max == "" then empty else "Max \($max)" end)]
    | join(" · ")' 2>/dev/null)

  response=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null |
    jq -r '"Authorization: Bearer \(.claudeAiOauth.accessToken // "")"' 2>/dev/null |
    curl -sS --proto '=https' --max-time 10 -H @- \
      -H 'anthropic-beta: oauth-2025-04-20' -H 'Accept: application/json' \
      -w '\n%{http_code}' https://api.anthropic.com/api/oauth/usage 2>/dev/null)
  code=${response##*$'\n'}
  response=${response%$'\n'*}

  case "$code" in
    200) ;;
    401|403) agents_status "$plan" "Signed out or token expired: run claude"; return ;;
    429)     agents_status "$plan" "Anthropic is rate limiting checks"; return ;;
    000|"")  agents_status "$plan" "Offline"; return ;;
    *)       agents_status "$plan" "Usage check failed (HTTP $code)"; return ;;
  esac

  printf '%s' "$response" | jq -c --arg plan "$plan" '
    def epoch: if . == null then null
      else sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601 end;
    {plan: $plan, status: "", limits: [
      (.five_hour  | select(. != null) | {label: "Session", percent: .utilization, resets: (.resets_at | epoch)}),
      (.seven_day  | select(. != null) | {label: "Weekly",  percent: .utilization, resets: (.resets_at | epoch)})
    ]}' 2>/dev/null || agents_status "$plan" "Unexpected answer from Anthropic"
}

# Codex reports its own limits over the app-server RPC, the way Omarchy reads
# them, so no credential passes through here. Closing stdin after a few
# seconds is what stops a stalled app-server from holding the bar's script.
agents_codex() {
  local response
  command -v codex >/dev/null 2>&1 || return 0

  response=$({
    printf '%s\n' \
      '{"id":1,"method":"initialize","params":{"clientInfo":{"name":"dotfiles-bar","version":"1"}}}' \
      '{"method":"initialized","params":{}}' \
      '{"id":2,"method":"account/rateLimits/read","params":{}}'
    sleep 6
  } | codex app-server 2>/dev/null | grep -m1 '"id":2')

  if [[ -z $response ]]; then
    agents_status "" "No answer from codex app-server"
    return
  fi
  if printf '%s' "$response" | jq -e '.error' >/dev/null 2>&1; then
    agents_status "" "Signed out: run codex login"
    return
  fi

  printf '%s' "$response" | jq -c '
    def window_label: if . == 300 then "Session" elif . == 10080 then "Weekly"
      elif . != null and . % 60 == 0 then "\(. / 60)h" else "Limit" end;
    .result as $r
    | {plan: ($r.rateLimits.planType // "" | sub("^self_serve_"; "") | gsub("_"; " ")
             | split(" ") | map((.[:1] | ascii_upcase) + .[1:]) | join(" ")),
       status: "",
       limits: [ ($r.rateLimitsByLimitId // {codex: $r.rateLimits}) | to_entries[] | .value as $b
         | ($b.primary, $b.secondary) | select(. != null)
         | {label: ((if $b.limitId == "codex" or $b.limitName == null then "" else "\($b.limitName) " end)
                    + (.windowDurationMins | window_label)),
            percent: .usedPercent, resets: .resetsAt} ]}' 2>/dev/null ||
    agents_status "" "Unexpected answer from codex app-server"
}

# A record with no numbers, so the cached ones stay on show with the reason
agents_status() {
  jq -nc --arg plan "$1" --arg status "$2" '{plan: $plan, status: $status, limits: null}'
}
