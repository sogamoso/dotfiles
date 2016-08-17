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

# This will output something like:
# Sha1    Author initials   Date   Commit message
# 16b30fd <AO> 2015-10-01 Merge pull request #71 from kurko/transformations-update
# 8545fff <JC> 2015-09-30 Code review
# 8c9fbe8 <JC> 2015-09-29 Adds string case modification actions for transformations
#
# The commits that are Merge or Revert are made red.
alias gl="git log --pretty=format:'%C(yellow)%h %C(blue)<<%an>> %C(black)%ad%C(yellow)%d%Creset %s %Creset' --date=short --abbrev-commit | sed -e 's/<<\([A-Za-z]\).* \([A-Za-z]\).*>>/<\1\2>/' | sed ''/Merge/s//`printf "\033[31mMerge\033[0m"`/'' | sed ''/Revert/s//`printf "\033[31mRevert\033[0m"`/'' | less -rX"

alias rc_test='RAILS_ENV=test bundle exec rails console --sandbox'
alias db_migrate='bundle exec rake db:migrate db:rollback && bundle exec rake db:migrate'
alias db_setup='bundle exec rake db:setup'
alias db_redo='bundle exec rake db:migrate:redo'
