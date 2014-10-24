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
alias dotfiles="cd $HOME/src/dotfiles"
alias idot="cd $HOME/src/dotfiles && sh install-dotfiles && source ~/.zshrc"

alias gadd='git add --all && git status'
alias glog='git log'

alias rc_test='RAILS_ENV=test bundle exec rails console --sandbox'
alias db_migrate='bundle exec rake db:migrate db:rollback && bundle exec rake db:migrate'
alias db_setup='bundle exec rake db:setup'
alias db_redo='bundle exec rake db:migrate:redo'
