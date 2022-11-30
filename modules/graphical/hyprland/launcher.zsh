#! /usr/bin/env nix-shell
#! nix-shell -i zsh -p fzy kitty wl-clipboard pass

_sighandler() {
  kill -INT "$child" 2>/dev/null
}

################################################################################
# Passwords
#
pass_options() {
  prefix=${PASSWORD_STORE_DIR-~/.password-store}
  password_files=( "$prefix"/**/*.gpg )
  printf "password %s\n" ${${password_files%.gpg}#$prefix/}
  printf "username %s\n" ${${password_files%.gpg}#$prefix/}
}

username() {
  pass show "$@" | sed -n "s/^Username: *//p" | tr -d '\n' | wl-copy --foreground
}
password() {
  pass show -c0 "$@"
}

################################################################################
# Power
#
systemctl_options() {
  echo systemctl hibernate
  echo systemctl poweroff
  echo systemctl reboot
  echo systemctl suspend
}

################################################################################
# Run programs
#
run_options() {
  print -rl -- ${(ko)commands} | grep -v "^\\." | sed "s/^/run /"
}

run() {
  hyprctl dispatch exec $1
}


################################################################################
# Select Action
#
CHOSEN=$(cat <(systemctl_options) <(pass_options) <(run_options) | fzy --lines 40 | tail -n1)

if [ -n "$CHOSEN" ]
then
  PREFIX=$(echo $CHOSEN | sed "s/^\([^ ]*\) .*/\1/g")
  WORD=$(echo $CHOSEN | sed "s/^[^ ]* \(.*\)/\1/g")
  echo "$PREFIX" "$WORD"
  $PREFIX $WORD
fi
