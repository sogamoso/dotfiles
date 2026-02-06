alias r='bin/rails'
alias rc='bin/rails console'
alias rs='bin/rails server'
alias rr='bin/rails routes'
alias rdbc='bin/rails db:create'
alias rdbm='bin/rails db:migrate'
alias rdbr='bin/rails db:rollback'
alias rdbmr='bin/rails db:migrate:redo'
alias rdbs='bin/rails db:seed'
alias rdbp='bin/rails db:prepare'
alias rdbreset='bin/rails db:reset'

# Minitest
alias mtest='bin/rails test'
alias mtesta='bin/rails test:all'

# RSpec
alias rspec='bundle exec rspec'
alias rspeca='bundle exec rspec spec/'

# Test helper
t() {
  local first="${1-}"
  local usage="Usage: t spec/... [more spec files...] | t test/... [more test files...]"

  if [[ -z "$first" ]]; then
    echo "$usage"
    return 1
  fi

  if [[ "$first" == spec/* ]]; then
    bundle exec rspec "$@"
  elif [[ "$first" == test/* ]]; then
    bin/rails test "$@"
  else
    echo "$usage"
    return 1
  fi
}
