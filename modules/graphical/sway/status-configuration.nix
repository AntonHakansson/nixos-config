{ config, lib, pkgs, isLaptop ? false, ... }:
let
  mail-status = pkgs.writeShellScript "mail-status" ''
    mails=$(${pkgs.mblaze}/bin/mlist -N ~/mail/*/Inbox | wc -l)
    if [ "$mails" -gt 0 ]
    then
      echo "{ \"state\": \"Info\", \"text\": \"✉️ $mails\" }"
    else
      echo "{ \"state\": \"Idle\", \"text\": \"\" }"
    fi
  '';
in pkgs.writeText "configuration.toml" (''
  [theme]
  name = "gruvbox-light"

  [theme.overrides]
  idle_bg="#ffffff"
  idle_fg="#000000"
  info_bg="#6aaeff"
  info_fg="#000000"
  good_bg="#5ada88"
  good_fg="#000000"
  warning_bg="#f5df23"
  warning_fg="#000000"
  critical_bg="#ff8892"
  critical_fg="#000000"
  separator=""

  [icons]
  name = "awesome5"
'' + (lib.optionalString isLaptop ''
  [[block]]
  block = "battery"

  [[block]]
  block = "backlight"
'') + ''
  [[block]]
  block = "music"
  player = "firefox"
  buttons = ["prev", "play", "next"]
  marquee = false
  hide_when_empty = true

  [[block]]
  block = "sound"

  [[block]]
  block = "custom"
  json = true
  command = "${mail-status}"
  interval = 60
  # on_click = "mbsync -a && emacsclient --eval \"(mu4e-update-index)\""

  [[block]]
  block = "time"
  interval = 5
  format = "%a %d/%m %H:%M"
'')
