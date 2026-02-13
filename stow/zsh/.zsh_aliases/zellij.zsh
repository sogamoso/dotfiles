alias zdev="zellij --layout dev attach -c dev"
alias tab="zt"

zt() {
  local name="${1:-${PWD:t}}"
  command -v zellij >/dev/null 2>&1 || return 0
  [[ -n "$ZELLIJ" ]] || return 0
  zellij action rename-tab "$name"
}
