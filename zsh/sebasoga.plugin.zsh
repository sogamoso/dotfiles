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

# Editor
if [[ "$EDITOR" == "" ]] ; then
  export EDITOR="vim"
fi

# Aliases
alias code="cd $HOME/Code"
alias dotfiles="code/dotfiles"
alias idot="dotfiles && sh install-dotfiles"

alias gadd='git add --all && git status'
alias glog='git log'

alias rc_test='RAILS_ENV=test bundle exec rails console --sandbox'
alias db_migrate='bundle exec rake db:migrate db:test:prepare'
alias db_setup='bundle exec rake db:setup db:test:prepare'
alias db_redo='bundle exec rake db:migrate:redo'
