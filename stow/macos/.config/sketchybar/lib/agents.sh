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
    | [($sub | if . == "" or (. == "max" and $max != "") then empty else (.[:1] | ascii_upcase) + .[1:] end),
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

  # A model's own allowance shows up only in the limits array, in any window
  # (a weekly one only Fable draws from, say), named by the model and window
  printf '%s' "$response" | jq -c --arg plan "$plan" '
    def epoch: if . == null then null
      else sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601 end;
    def window: ascii_downcase
      | if test("month") then " monthly" elif test("week|day") then " weekly"
        elif test("hour|session") then " session" else "" end;
    {plan: $plan, status: "", limits: [
      (.five_hour  | select(.utilization != null) | {label: "Session", percent: .utilization, resets: (.resets_at | epoch)}),
      (.seven_day  | select(.utilization != null) | {label: "Weekly",  percent: .utilization, resets: (.resets_at | epoch)}),
      ([.limits[]? | select(.percent != null)
        | {name: (.scope.model.display_name // .scope.model.id // ""), kind: (.kind // ""), percent, resets_at}
        | select(.name != "")]
        | reduce .[] as $l ([]; if any(.[]; .name == $l.name and .kind == $l.kind) then . else . + [$l] end) | .[]
        | {label: "\(.name)\(.kind | window)", percent, resets: (.resets_at | epoch)})
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
  # Only an auth error is a sign-out; anything else says what went wrong
  if printf '%s' "$response" | jq -e '.error' >/dev/null 2>&1; then
    agents_status "" "$(printf '%s' "$response" | jq -r '.error.message // "" |
      if test("auth"; "i") then "Signed out: run codex login" else "Codex limits unavailable" end')"
    return
  fi

  # Plans as Codex's own /status names them; a newer one keeps its wire name.
  # A spend cap (seen on Business seats) comes with a reset but no period.
  printf '%s' "$response" | jq -c '
    def window_label: if . == 300 then "Session" elif . == 10080 then "Weekly"
      elif . != null and . % 60 == 0 then "\(. / 60)h" else "Limit" end;
    def plan_name: {free: "Free", go: "Go", plus: "Plus", pro: "Pro 200", prolite: "Pro 100",
      promax: "Pro 500", team: "Business", self_serve_business_usage_based: "Business",
      self_serve_business_prolite: "Business Premium", business: "Enterprise",
      enterprise_cbp_automation: "Enterprise (Automation)", enterprise_cbp_usage_based: "Enterprise",
      ent26: "Enterprise", enterprise: "Enterprise", edu: "Edu", edu_plus: "Edu Plus",
      edu_pro: "Edu Pro"}[.] // gsub("_"; " ");
    .result as $r
    | ($r.rateLimitsByLimitId // {codex: $r.rateLimits}) as $buckets
    | {plan: ([$buckets[]?.planType, $r.rateLimits.planType | strings] | first // "" | plan_name),
       status: "",
       limits: [ $buckets | to_entries[] | .value as $b
         | ($b.primary, $b.secondary) | select(. != null)
         | {label: ((if $b.limitId == "codex" or $b.limitName == null then "" else "\($b.limitName) " end)
                    + (.windowDurationMins | window_label)),
            percent: .usedPercent, resets: .resetsAt} ]
         + ([$buckets[]?.individualLimit, $r.rateLimits.individualLimit | objects] | first // null
            | if . == null then [] else
                [{label: "Spend limit",
                  percent: (if (.limit // 0) > 0 and .used != null then 100 * .used / .limit
                            else 100 - (.remainingPercent // 100) end),
                  resets: .resetsAt}] end)
         + ([$r.rateLimitResetCredits.credits[]? | select(.status == "available")] as $free
            | if ($free | length) == 0 then [] else
                [{label: "Free resets", text: "\($free | length) available",
                  resets: ($free | map(.expiresAt) | min)}] end)}' 2>/dev/null ||
    agents_status "" "Unexpected answer from codex app-server"
}

# Cursor's CLI keeps its login in the keychain on macOS. Usage comes from the
# dashboard service the CLI itself calls, as Omarchy's collector does. Like
# Claude's, the token reaches curl through pipes only and goes nowhere else.
agents_cursor() {
  local usage plan
  security find-generic-password -s cursor-access-token >/dev/null 2>&1 || return 0

  usage=$(agents_cursor_call GetCurrentPeriodUsage) || { agents_status "" "$usage"; return; }
  plan=$(agents_cursor_call GetPlanInfo) || plan='{}'

  # The included allowance runs on the billing cycle unless the plan says it's
  # weekly (an enum that arrives as 2 or as its name), with its own reset. The
  # on-demand budget always runs on the billing cycle. Timestamps are
  # milliseconds, though one small enough to be seconds is read as seconds.
  jq -nc --argjson u "$usage" --argjson p "$plan" '
    def epoch: tonumber? // 0 | if . > 0 and . < 100000000000 then . else . / 1000 end | floor;
    def dollars: round | "$\(. / 100 | floor).\(. % 100 | tostring | if length < 2 then "0" + . else . end)";
    ($p.planInfo // {}) as $plan
    | ($plan.includedUsagePeriod | . == 2 or ((strings | ascii_upcase | test("WEEKLY")) // false)) as $weekly
    | ($u.billingCycleEnd | epoch) as $cycle
    | (if $weekly then ($plan.includedUsageResetsAt | epoch) else $cycle end) as $resets
    | ($u.planUsage // {}) as $use
    | ($u.spendLimitUsage // {}) as $spend
    | {plan: ($plan.planName // ""), status: "", limits: [
        ([["totalPercentUsed", (if $weekly then "Weekly" else "Monthly" end)],
          ["autoPercentUsed", "Auto models"], ["apiPercentUsed", "Named models"]][]
          | .[0] as $key | select($use | has($key)) | {label: .[1], percent: $use[$key], resets: $resets}),
        (($spend.individualLimit // 0 | tonumber) as $cap | select($cap > 0)
          | ($spend.individualUsed // 0 | tonumber) as $used
          | {label: "On-demand \($used | dollars) / \($cap | dollars)",
             percent: (100 * $used / $cap), resets: $cycle})
      ]}' 2>/dev/null ||
    agents_status "" "Unexpected answer from Cursor"
}

# Prints the answer, or the reason it failed, which is what the caller shows
agents_cursor_call() {
  local response code
  response=$(security find-generic-password -s cursor-access-token -w 2>/dev/null |
    sed 's/^/Authorization: Bearer /' |
    curl -sS --proto '=https' --max-time 10 -X POST -H @- \
      -H 'Content-Type: application/json' -H 'Connect-Protocol-Version: 1' -H 'x-cursor-client-type: cli' \
      -d '{}' -w '\n%{http_code}' "https://api2.cursor.sh/aiserver.v1.DashboardService/$1" 2>/dev/null)
  code=${response##*$'\n'}
  case "$code" in
    200)     printf '%s' "${response%$'\n'*}" ;;
    401|403) echo "Signed out: run cursor-agent login"; return 1 ;;
    000|"")  echo "Offline"; return 1 ;;
    *)       echo "Usage check failed (HTTP $code)"; return 1 ;;
  esac
}

# Grok keeps its login in ~/.grok/auth.json on every platform, and asks the
# same billing endpoint its /usage view does. Its access token lives six hours
# and Grok mints a new one whenever it starts, so a lapsed one isn't a sign-out.
agents_grok() {
  local auth="${GROK_HOME:-$HOME/.grok}/auth.json" plan expires credits monthly='{}' code
  [[ -f $auth ]] || return 0
  plan=$(jq -r '.payload | fromjson | .settings.subscription_tier_display // ""' \
    "${GROK_HOME:-$HOME/.grok}/settings_cache.json" 2>/dev/null)

  expires=$(jq -r 'to_entries[0].value.expires_at // empty | sub("\\.[0-9]+"; "") | sub("Z$"; "") + "Z" | fromdateiso8601' "$auth" 2>/dev/null)
  if [[ -n $expires ]] && (( expires <= $(date +%s) )); then
    agents_status "$plan" "Token lapsed: run grok to renew it"
    return
  fi

  credits=$(agents_grok_call 'https://cli-chat-proxy.grok.com/v1/billing?format=credits') || {
    agents_status "$plan" "$credits"; return; }
  # A unified-billing account can also carry a monthly quota; a quota of zero
  # means there is none
  if jq -e '.config.isUnifiedBillingUser == true' <<<"$credits" >/dev/null 2>&1; then
    monthly=$(agents_grok_call 'https://cli-chat-proxy.grok.com/v1/billing') || monthly='{}'
  fi

  jq -nc --arg plan "$plan" --argjson c "$credits" --argjson m "$monthly" '
    def epoch: sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601;
    $c.config as $cc
    | {plan: $plan, status: "", limits: [
        ($cc.currentPeriod | select(. != null)
          | {label: (if (.type // "" | test("WEEK")) then "Weekly" else "Monthly" end),
             percent: ($cc.creditUsagePercent // 0), resets: (.end | epoch)}),
        ($m.config // {} | select((.monthlyLimit.val // 0) > 0)
          | {label: "Monthly", percent: (100 * (.used.val // 0) / .monthlyLimit.val),
             resets: (.billingPeriodEnd | epoch)})
      ]}' 2>/dev/null || agents_status "$plan" "Unexpected answer from Grok"
}

agents_grok_call() {
  local response code
  response=$(jq -r 'to_entries[0].value | "Authorization: Bearer \(.key)"' "${GROK_HOME:-$HOME/.grok}/auth.json" 2>/dev/null |
    curl -sS --proto '=https' --max-time 8 -H @- -H 'Accept: application/json' \
      -w '\n%{http_code}' "$1" 2>/dev/null)
  code=${response##*$'\n'}
  case "$code" in
    200)     printf '%s' "${response%$'\n'*}" ;;
    401|403) echo "Signed out: run grok login"; return 1 ;;
    000|"")  echo "Offline"; return 1 ;;
    *)       echo "Usage check failed (HTTP $code)"; return 1 ;;
  esac
}

# A record with no numbers, so the cached ones stay on show with the reason
agents_status() {
  jq -nc --arg plan "$1" --arg status "$2" '{plan: $plan, status: $status, limits: null}'
}
