#!/usr/bin/env bash
# Sourced by plugins/agents.sh and sketchybarrc — never run directly.
#
# The widget draws one record per agent in the shape Omarchy's agents panel
# reads (docs/agent-usage-collectors.md in the checkout): id, name, ready,
# tierLabel, usageStatusText, limits as [{label, title, percent 0..1,
# resetsAt}], limitsStale, limitsFetchedAt, balance and the local stats block.
# Omarchy's own collectors print them, run from the pinned checkout that
# install/macos/omarchy-agents.sh keeps at Omarchy's own path. Two agents need
# help: Cursor keeps its token in the keychain, where Omarchy's collector
# doesn't look, so the collector is handed it through the CURSOR_AUTH_TOKEN
# its contract names; Gemini CLI has no collector, so agents_gemini fetches
# its limits and agents_record wraps them into the same shape.

OMARCHY_PATH=${OMARCHY_PATH:-$HOME/.local/share/omarchy}
export OMARCHY_PATH
# The collectors need Python 3.11; Homebrew's, which is on the bar's PATH
AGENTS_PYTHON=/opt/homebrew/bin/python3

# Every agent that can have a record here, in Omarchy's order
agents_ids() {
  {
    local collector
    for collector in "$OMARCHY_PATH"/bin/omarchy-agent-usage-*; do
      [[ -f $collector ]] || continue
      collector=${collector##*/omarchy-agent-usage-}
      [[ $collector == update ]] || echo "$collector"
    done
    echo gemini
  } | sort
}

# Writes the agent's record to $1/<id>.json, or removes it when the agent
# isn't used here. $3 is --force on a click. A collector that fails leaves
# the last record in place, as Omarchy's updater does.
agents_collect() {
  local cache=$1 id=$2 flag=${3:-} record
  case "$id" in
    gemini) record=$(agents_record gemini "Gemini CLI" "$cache/gemini.json" agents_gemini) ;;
    *)      record=$(agents_collector "$id" ${flag:+"$flag"}) ;;
  esac
  if [[ -z $record ]] || ! printf '%s' "$record" | jq -e . >/dev/null 2>&1; then
    return 1
  elif [[ "$(printf '%s' "$record" | jq -r '.ready')" == "true" ]]; then
    printf '%s\n' "$record" >"$cache/$id.tmp" && mv "$cache/$id.tmp" "$cache/$id.json"
  else
    rm -f "$cache/$id.json"
  fi
}

# One of Omarchy's collectors, with mise's agents on PATH (Codex's runs
# codex app-server) and a deadline, since a stuck one would hold the bar's
# script. The keychain token Cursor's gets is set for that process alone.
agents_collector() {
  local id=$1 collector="$OMARCHY_PATH/bin/omarchy-agent-usage-$1"
  shift
  [[ -x $AGENTS_PYTHON && -f $collector ]] || return 1
  local PATH="$PATH:$HOME/.local/share/mise/shims"
  if [[ $id == cursor ]] && security find-generic-password -s cursor-access-token >/dev/null 2>&1; then
    CURSOR_AUTH_TOKEN="$(security find-generic-password -s cursor-access-token -w 2>/dev/null)" \
      perl -e 'alarm shift; exec @ARGV' 90 "$AGENTS_PYTHON" "$collector" "$@" 2>/dev/null
  else
    perl -e 'alarm shift; exec @ARGV' 90 "$AGENTS_PYTHON" "$collector" "$@" 2>/dev/null
  fi
}

# Wraps a fetcher's {plan, status, limits: [{label, percent 0..100, resets
# epoch}]} into the record shape. A fetcher that reports why it has no numbers
# keeps the last record's limits, marked stale, with the reason.
agents_record() {
  local id=$1 name=$2 last=$3 fetcher=$4 record
  record=$("$fetcher")
  [[ -f $last ]] || last=/dev/null
  jq -c --arg id "$id" --arg name "$name" --argjson now "$(date +%s)" --slurpfile old "$last" '
    ($old[0] // {}) as $old
    | {schemaVersion: 1, id: $id, name: $name, ready: (. != null), updatedAt: ($now | todate),
       tierLabel: (.plan // $old.tierLabel // ""), hasLocalStats: false, hasPromptStats: false,
       todayPrompts: 0, todaySessions: 0, todayTotalTokens: 0, todayTokensByModel: {}, recentDays: [],
       totalPrompts: 0, totalSessions: 0, activeDays: 0, activeDates: [], modelUsage: {}}
      + (if .limits == null then
           {usageStatusText: (.status // ""), limits: ($old.limits // []), limitsStale: true,
            limitsFetchedAt: ($old.limitsFetchedAt // 0)}
         else
           {usageStatusText: "", limitsStale: false, limitsFetchedAt: ($now * 1000),
            limits: [.limits[] | {label, percent: (.percent / 100),
                                  resetsAt: (if .resets == null then "" else (.resets | todate) end)}]}
         end)' <<<"${record:-null}" 2>/dev/null
}

# Gemini CLI has limits to show only when signed in with Google: the Code
# Assist API the CLI itself asks gives the plan and project (loadCodeAssist)
# and each model's allowance (retrieveUserQuota). An API key has no quota to
# read, so it shows as the plan with no meters. The sign-in is read where the
# CLI keeps it, the macOS keychain or its encrypted credentials file, and
# reaches curl through pipes only, bound for cloudcode-pa.googleapis.com and
# nowhere else. The access token lives an hour and the CLI renews it whenever
# it runs, so a lapsed one isn't a sign-out.
agents_gemini() {
  local settings="$HOME/.gemini/settings.json" login assist plan project quota
  [[ -f $settings ]] || return 0
  case "$(jq -r '.security.auth.selectedType // ""' "$settings" 2>/dev/null)" in
    gemini-api-key) jq -nc '{plan: "API key", status: "", limits: []}'; return ;;
    oauth-personal) ;;
    *) return 0 ;;
  esac

  # none, or when the token lapses in epoch milliseconds, 0 when unknown
  login=$(agents_gemini_login | jq -r '
    if (.token.accessToken // "") == "" then "none" else (.token.expiresAt // 0 | floor | tostring) end' 2>/dev/null)
  case "$login" in
    none|"") agents_status "" "Signed out: run gemini to sign in"; return ;;
    0) ;;
    *) if (( login / 1000 <= $(date +%s) )); then
         agents_status "" "Token lapsed: run gemini to renew it"
         return
       fi ;;
  esac

  assist=$(agents_gemini_call loadCodeAssist \
    '{"metadata":{"ideType":"IDE_UNSPECIFIED","platform":"PLATFORM_UNSPECIFIED","pluginType":"GEMINI"}}') || {
    agents_status "" "$assist"; return; }
  plan=$(printf '%s' "$assist" | agents_gemini_plan)
  project=$(printf '%s' "$assist" |
    jq -r '.cloudaicompanionProject | if type == "object" then .id else . end // ""' 2>/dev/null)
  if [[ -z $project ]]; then
    agents_status "$plan" "No Code Assist project yet: run gemini once"
    return
  fi

  quota=$(agents_gemini_call retrieveUserQuota "$(jq -nc --arg project "$project" '{project: $project}')") || {
    agents_status "$plan" "$quota"; return; }
  printf '%s' "$quota" | agents_gemini_limits "$plan" || agents_status "$plan" "Unexpected answer from Google"
}

# The tier as Omarchy labels it: Free, Pro or Ultra wherever the id or name
# says so, otherwise the name less its "Google AI" prefix
agents_gemini_plan() {
  jq -r '(.paidTier // .currentTier // {}) | (.name // "") as $name | (.id // "") as $id
    | ($id + " " + $name | ascii_downcase) as $all
    | if ($all | test("ultra")) then "Ultra" elif ($all | test("pro")) then "Pro"
      elif ($all | test("free")) then "Free"
      elif ($name | ascii_downcase | startswith("google ai ")) then ($name | .[10:] | ltrimstr(" "))
      elif $name != "" then $name
      else ($id | sub("-tier$"; "") | (.[:1] | ascii_upcase) + .[1:]) end' 2>/dev/null
}

# One meter per model, the most used first. A bucket's remainder is a
# fraction, or an amount whose zero means spent; proto3 JSON leaves zero
# values out, so a bucket with neither but a reset time is spent too.
agents_gemini_limits() {
  jq -c --arg plan "$1" '
    def epoch: if . == null then null
      else sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | (try fromdateiso8601 catch null) end;
    def title: sub("^gemini-"; "") | split("-") | map((.[:1] | ascii_upcase) + .[1:]) | join(" ");
    def used: if .disabled == true then null
      elif .remainingFraction != null then 100 * (1 - .remainingFraction)
      elif .remainingAmount != null then (if (.remainingAmount | tostring) == "0" then 100 else null end)
      elif (.resetTime | epoch) != null then 100 else null end;
    {plan: $plan, status: "", limits: [
      .buckets[]? | select(.modelId != null)
      | {label: (.modelId | title), percent: used, resets: (.resetTime | epoch)}
      | select(.percent != null)
      | .percent |= (if . < 0 then 0 elif . > 100 then 100 else . end)]
      | unique_by(.label) | sort_by(-.percent)}' 2>/dev/null
}

# Prints the answer, or the reason it failed, which is what the caller shows
agents_gemini_call() {
  local response code
  response=$(agents_gemini_login |
    jq -r '"Authorization: Bearer \(.token.accessToken // "")"' 2>/dev/null |
    curl -sS --proto '=https' --max-time 10 -X POST -H @- -H 'Content-Type: application/json' \
      -d "$2" -w '\n%{http_code}' "https://cloudcode-pa.googleapis.com/v1internal:$1" 2>/dev/null)
  code=${response##*$'\n'}
  case "$code" in
    200)     printf '%s' "${response%$'\n'*}" ;;
    401|403) echo "Signed out or token expired: run gemini"; return 1 ;;
    429)     echo "Google is rate limiting checks"; return 1 ;;
    000|"")  echo "Offline"; return 1 ;;
    *)       echo "Usage check failed (HTTP $code)"; return 1 ;;
  esac
}

# The sign-in as the CLI stores it, {token: {accessToken, expiresAt}}, from
# the keychain or the encrypted file; nothing when there is none
agents_gemini_login() {
  # node is mise's, which Homebrew's SketchyBar service doesn't have on PATH
  local PATH="$PATH:$HOME/.local/share/mise/shims"
  if security find-generic-password -s gemini-cli-oauth -a main-account >/dev/null 2>&1; then
    security find-generic-password -s gemini-cli-oauth -a main-account -w 2>/dev/null
  elif [[ -f $HOME/.gemini/gemini-credentials.json ]]; then
    node "${CONFIG_DIR:-$HOME/.config/sketchybar}/lib/gemini-login.js" 2>/dev/null
  fi
}

# A record with no numbers, so the cached ones stay on show with the reason
agents_status() {
  jq -nc --arg plan "$1" --arg status "$2" '{plan: $plan, status: $status, limits: null}'
}
