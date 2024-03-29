#!@zsh@/bin/zsh

_sighandler() {
  kill -INT "$child" 2>/dev/null
}

calc_options() {
  echo "calc "
}

calc() {
  if [ -n "$1" ]
  then
    @libqalculate@/bin/qalc "$1"
    sleep 5
  else
    @libqalculate@/bin/qalc
  fi
}

emoji_options() {
  cat @emojiList@ | sed "s/^/emoji /"
}

emoji() {
  char=$(echo -n "$1" | sed "s/^\([^ ]*\) .*/\1/")
  @sway@/bin/swaymsg exec -- "echo -n $char | @wlClipboard@/bin/wl-copy --foreground"
}

pass_options(){
  prefix=${PASSWORD_STORE_DIR-~/.password-store}
  password_files=( "$prefix"/**/*.gpg )
  printf 'password %s\n' ${${password_files%.gpg}#$prefix/}
  printf 'username %s\n' ${${password_files%.gpg}#$prefix/}
}

username() {
  swaymsg exec -- "@pass@/bin/pass show '$@' | sed -n 's/^Username: *//p' | tr -d '\n' | @wlClipboard@/bin/wl-copy --foreground"
}
password() {
  swaymsg exec -- "@pass@/bin/pass show -c0 '$@'"
}

record_options() {
  @sway@/bin/swaymsg -t get_outputs | @jq@/bin/jq -r '.[]["name"]' | sed "s/^/record /"
  echo record select
}

record() {
  filename="$(@xdgUserDirs@/bin/xdg-user-dir VIDEOS)/$(date +'screenrecording_%y-%m-%d-%H%M%S.mp4')"

  trap _sighandler SIGINT
  if [[ "$1" = "select" ]]
  then
    @wfRecorder@/bin/wf-recorder -g "$(@slurp@/bin/slurp)" -f "$filename" &
  else
    @wfRecorder@/bin/wf-recorder -o $! -f "$filename" &
  fi
  child=$!
  wait "$child"
  # We wait two times, because the first wait exits when the process receives a signal. The process might have finished though, so we ignore errors.
  wait "$child" 2>/dev/null
  if [ -f "$filename" ]
  then
    echo "Saved as $filename"
  else
    echo "Something went wrong while recording"
  fi
  sleep 5
}

run_options() {
  print -rl -- ''${(ko)commands} | grep -v "^\\." | sed "s/^/run /"
}

run() {
  @sway@/bin/swaymsg exec $1
}

ssh_options() {
  cat $HOME/.ssh/config | grep "^Host [a-zA-Z]\+" | sed "s/Host /ssh /"
}

ssh() {
  @sway@/bin/swaymsg exec "@kitty@/bin/kitty -e ssh $1"
}

systemctl_options() {
  echo systemctl hibernate
  echo systemctl poweroff
  echo systemctl reboot
  echo systemctl suspend
}

theme_options() {
  echo theme modus-operandi
  echo theme onedark
}

theme() {
  if [[ ! -f /etc/nixos/flake.nix ]]
  then
    echo "Error: create a '/etc/nixos/flake.nix' symlink to your local repo's flake.nix"
    echo "\t> ln /etc/nixos/flake.nix /home/hakanssn/repo/nixos-config/flake.nix"
    read
    exit
  fi
  theme=$(echo $@ | cut -d' ' -f 2)
  echo "Switching to theme '$theme'"
  doas env THEME="$theme" nixos-rebuild switch --impure
}

CHOSEN=$(cat <(ssh_options) <(systemctl_options) <(theme_options) <(pass_options) <(run_options) <(record_options) <(calc_options) <(emoji_options) | @fzy@/bin/fzy --lines 40 | tail -n1)

if [ -n "$CHOSEN" ]
then
  PREFIX=$(echo $CHOSEN | sed "s/^\([^ ]*\) .*/\1/g")
  WORD=$(echo $CHOSEN | sed "s/^[^ ]* \(.*\)/\1/g")

  $PREFIX $WORD
fi
