alias gc='git commit'
alias gst='git status -sb'
alias gaa='git add -A'
alias gap='git add -p'
alias gds='git diff --staged'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias glg='git log --oneline --decorate --graph --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gbd='git branch -d'
alias gsw='git switch'
alias gswc='git switch -c'
alias gp='git push -u origin HEAD'
alias gpf='git push --force-with-lease'
alias gf='git fetch --prune'
alias gpull='git pull --ff-only'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'

# Sync current branch safely
gsync() { git fetch origin --prune && git pull --ff-only; }

# Switch to main/master and sync
gswm() {
  local base

  if git show-ref --verify --quiet refs/heads/main || git show-ref --verify --quiet refs/remotes/origin/main; then
    base="main"
  elif git show-ref --verify --quiet refs/heads/master || git show-ref --verify --quiet refs/remotes/origin/master; then
    base="master"
  else
    echo "No base branch found (main or master)."
    return 1
  fi

  git switch "$base" 2>/dev/null || git switch -c "$base" --track "origin/$base"
  gsync
}

# New branch off latest main/master
gbc() {
  if [[ -z "${1-}" ]]; then
    echo "Usage: gbc <branch-name>"
    return 1
  fi
  gswm && gswc "$1"
}

# Force-delete a branch, removing its worktree first if one exists
gbD() {
  local branch="${1:?Usage: gbD <branch>}"
  local worktree
  worktree=$(git worktree list --porcelain | awk -v b="$branch" '/^worktree /{wt=$2} $0 == "branch refs/heads/" b {print wt}')
  if [[ -n "$worktree" ]]; then
    echo "Removing worktree: $worktree"
    git worktree remove --force "$worktree"
  fi
  git branch -D "$branch"
}

# Override Omadots' gd (worktree remover) with git diff
gd() { git diff "$@"; }

# Omadots' worktree remover, renamed
gwrm() {
  if gum confirm "Remove worktree and branch?"; then
    local cwd base branch root worktree
    cwd="$(pwd)"
    worktree="$(basename "$cwd")"
    root="${worktree%%--*}"
    branch="${worktree#*--}"
    if [[ "$root" != "$worktree" ]]; then
      cd "../$root"
      git worktree remove "$cwd" --force || return 1
      git branch -D "$branch"
    fi
  fi
}
