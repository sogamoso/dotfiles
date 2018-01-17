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
alias code="cd $HOME/src"
alias db_prepare='bundle exec rake db:reset db:setup'
alias db_redo='bundle exec rake db:migrate:redo'
alias dotfiles="cd $HOME/src/dotfiles"
alias gadd='git add --all && git status'
alias gc='git commit -S'
alias gcm='git checkout master'
alias github_notifications='open https://github.com/notifications'
alias glog='git log'
alias gp='git push'
alias gpf='git push -f'
alias gpr='git pull --rebase'
alias gr='git rebase'
alias gt='git tag -s'
alias rerun_dotfiles="cd $HOME/src/dotfiles && sh install-dotfiles && source ~/.zshrc"
alias rc_test='RAILS_ENV=test bundle exec rails console --sandbox'
alias start_day='open https://gist.github.com/sebasoga/e9d3ed93b8b51cf6e389b14c7d03717d'
