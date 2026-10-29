#!/usr/bin/env bash
# herdr's server for the Mac mini's LaunchAgent (com.sogamoso.herdr-server),
# running in the GUI login session.
#
# Left to herdr, the mini's server starts with the first remote attach, inside
# that Tailscale SSH login, whose securityd session has no login keychain, and
# every pane inherits that: cursor-agent reports the keychain locked and
# Claude Code can't read its credentials (herdr#966). A GUI-session LaunchAgent
# has the keychain, but herdr counts a server as able to outlive an SSH drop
# only when it leads a session of its own, as its auto-started one does, and
# otherwise offers a restart on every attach from a saved machine (herdr#4205).
# launchd's child is already a process group leader, which setsid refuses, so
# the server is forked into a new session and this process stays for launchd
# to track, passing on its termination and exiting with the server's status.
set -euo pipefail

command -v herdr >/dev/null 2>&1 || { echo "herdr-server: herdr isn't on PATH" >&2; exit 1; }

exec /usr/bin/perl -e '
  use POSIX ();
  my $pid = fork();
  defined $pid or die "fork: $!";
  if ($pid == 0) {
    POSIX::setsid() != -1 or die "setsid: $!";
    exec @ARGV or die "exec $ARGV[0]: $!";
  }
  for my $signal (qw(TERM INT HUP)) {
    $SIG{$signal} = sub { kill $_[0], $pid };
  }
  1 while waitpid($pid, 0) == -1 && $!{EINTR};
  exit(($? & 127) ? 128 + ($? & 127) : $? >> 8);
' -- herdr server
