{ config, lib, pkgs, ... }:
let
  mail-status = pkgs.writeShellScript "mail-status" ''
    mails=$(${pkgs.mblaze}/bin/mlist -N ~/mail/*/Inbox | wc -l)
    if [ "$mails" -gt 0 ]
    then
      echo "{ \"state\": \"Info\", \"text\": \"✉️ $mails\" }"
    else
      echo "{ \"state\": \"Idle\", \"text\": \"✉️\" }"
    fi
  '';
  c = config.asdf.graphical.theme.colorscheme.colors;
in pkgs.writeText "configuration.toml" (''
  [theme]
  name = "dracula"

  [theme.overrides]
  idle_bg="${c.base00}"
  idle_fg="${c.base05}"
  separator=""

  [icons]
  name = "awesome5"
'' + (lib.optionalString config.asdf.graphical.laptop ''
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
  block = "custom"
  json = true
  command = "${mail-status}"
  interval = 60
  on_click = "mbsync -a && mu index"

  [[block]]
  block = "sound"

  [[block]]
  block = "time"
  interval = 5
  format = "%a %d/%m %H:%M"
'')
