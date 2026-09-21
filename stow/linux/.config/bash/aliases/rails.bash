alias rc='rails console'
alias rs='rails server'
alias rr='rails routes'
alias rdbc='rails db:create'
alias rdbm='rails db:migrate'
alias rdbr='rails db:rollback'
alias rdbmr='rails db:migrate:redo'
alias rdbs='rails db:seed'
alias rdbp='rails db:prepare'
alias rdbreset='rails db:reset'

# Minitest
alias mtest='rails test'
alias mtesta='rails test:all'

# RSpec
alias rspec='bundle exec rspec'
alias rspeca='bundle exec rspec spec/'

# Test helper
rt() {
  local first="${1-}"
  local usage="Usage: rt spec/... [more spec files...] | rt test/... [more test files...]"

  if [[ -z "$first" ]]; then
    echo "$usage"
    return 1
  fi

  if [[ "$first" == spec/* ]]; then
    bundle exec rspec "$@"
  elif [[ "$first" == test/* ]]; then
    rails test "$@"
  else
    echo "$usage"
    return 1
  fi
}
