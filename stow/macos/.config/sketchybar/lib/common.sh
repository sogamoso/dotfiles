#!/usr/bin/env bash
# Sourced by sketchybarrc and the plugins — never run directly.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
CACHE_DIR="$HOME/.cache/sketchybar"

# Stamped by sketchybarrc once a rebuild finishes, read by display_change.sh.
RELOAD_STAMP="${TMPDIR:-/tmp}/dotfiles-sketchybar-reload"

# Build a Swift helper into CACHE_DIR, remembering a failure so it isn't
# retried on every bar reload. When the Command Line Tools lag the installed
# SDK every swiftc call fails, and two failing compiles stretch a config run
# past the reload debounce — which is what turns one display_change into an
# endless reload loop. `dotfiles reload` clears the markers, so a repaired
# toolchain gets picked up without hunting for them.
build_swift() {
  local src=$1 bin=$2
  shift 2
  local failed="$bin.failed"

  mkdir -p "$CACHE_DIR"
  [[ -f $bin && ! $src -nt $bin ]] && return 0
  [[ -f $failed && ! $src -nt $failed ]] && return 1

  if swiftc "$src" -o "$bin" "$@" 2>/dev/null; then
    rm -f "$failed"
  else
    touch "$failed"
    return 1
  fi
}

# Succeed at most once per <seconds> for a given name, so a trackpad swipe,
# which sends dozens of scroll events, acts once. The lock keeps two events
# that land together from both getting through; bash 3.2 has no clock finer
# than a second, hence perl.
debounce() {
  local name=$1 seconds=$2
  /usr/bin/perl -e '
    use Fcntl ":flock"; use Time::HiRes "time";
    open my $f, "+>>", $ARGV[0] or exit 1;
    flock $f, LOCK_EX; seek $f, 0, 0;
    my $last = <$f> // 0;
    exit 1 if time - $last < $ARGV[1];
    truncate $f, 0; print $f time;
  ' "${TMPDIR:-/tmp}/dotfiles-sketchybar-$name.debounce" "$seconds"
}
