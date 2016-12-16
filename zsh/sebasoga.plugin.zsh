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
alias gcm='git checkout master'
alias glog='git log'
alias gp='git push'
alias gpf='git push -f'
alias gpr='git pull --rebase'
alias gr='git rebase'
alias rerun_dotfiles="cd $HOME/src/dotfiles && sh install-dotfiles && source ~/.zshrc"
alias rc_test='RAILS_ENV=test bundle exec rails console --sandbox'
alias start_day='open https://gist.github.com/sebasoga/8d296609d50712d80b4cb3cdab247087'
