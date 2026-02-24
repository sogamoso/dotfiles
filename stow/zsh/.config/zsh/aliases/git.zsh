alias gc='git commit'
alias gst='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gd='git diff'
alias gds='git diff --staged'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias glg='git log --oneline --decorate --graph --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gsw='git switch'
alias gsc='git switch -c'
alias gp='git push -u origin HEAD'
alias gpf='git push --force-with-lease'
alias gpull='git pull --ff-only'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'

# Sync current branch safely
gsync() { git fetch origin --prune && git pull --ff-only; }

# Keep main clean and updated
gmain() { git switch main && gsync; }

# New branch off latest main
gnew() {
  if [[ -z "${1-}" ]]; then
    echo "Usage: gnew <branch-name>"
    return 1
  fi
  gmain && git switch -c "$1"
}
