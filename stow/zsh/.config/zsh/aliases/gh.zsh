alias ghpr='gh pr create --fill'
alias ghprw='gh pr view --web'
alias ghprc='gh pr checks'
alias ghprr='gh pr review'
alias ghprs='gh pr status'
alias ghrepo='gh repo view --web' # Open current repo in browser

# Check out a PR by number: ghco 123
ghco() { gh pr checkout "$@"; }
