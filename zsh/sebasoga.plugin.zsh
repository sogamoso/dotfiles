# Functions
function grepp(){
  grep -Rni --exclude=".//db/data*" --exclude=".//tmp*" --exclude=".//vendor*" --exclude=".//coverage*" --exclude=".//log*" --exclude=".//tag*" --exclude=".//spec*/cassett*" --exclude=".//public/*.js*" --exclude=".//.*" "$*" ./
}

function findd(){
  find . -ipath "*$**"
}

function reload(){
  source ~/.zshrc
}

function tmuxa(){ tmux attach -t $*; }
function tmuxn(){ tmux new-session -s $*; }
function tmuxk(){ tmux kill-session -t $*; }

# Editor
if [[ "$EDITOR" == "" ]] ; then
  export EDITOR="vim"
fi

# Aliases
alias dotfiles="cd $HOME/Code/dotfiles"
alias gadd='git add --all && git status'
alias ganew='git add . -N'
alias gap='git add --patch'
alias gc='git commit -S'
alias gcm='git checkout main'
alias glog='git log'
alias gpull='git pull'
alias gpush='git push'
alias gr='git rebase'
alias gt='git tag -s'
