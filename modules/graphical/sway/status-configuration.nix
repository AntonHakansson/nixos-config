{ config, lib, pkgs, ... }:
let
  mail-status = pkgs.writeShellScript "mail-status" ''
    mails=$(${pkgs.mblaze}/bin/mlist -N ~/mail/*/Inbox | wc -l)
    if [ "$mails" -gt 0 ]
    then
      echo "{ \"state\": \"Info\", \"text\": \"\uf0e0 $mails\" }"
    else
      echo "{ \"state\": \"Idle\", \"text\": \"\" }"
    fi
  '';
in pkgs.writeText "configuration.toml" (""
  + (lib.optionalString config.asdf.graphical.laptop ''
    [[block]]
    block = "battery"

    [[block]]
    block = "backlight"
  '') + ''
    [[block]]
    block = "music"
    marquee = false # don't scroll text
    buttons = [ "play", "next" ]
    smart_trim = true
    dynamic_width = true
    hide_when_empty = true
    format = "{combo} "

    [[block]]
    block = "custom"
    json = true
    command = "${mail-status}"
    interval = 60
    on_click = "mbsync -a && mu index"
    hide_when_empty = true

    [[block]]
    block = "sound"
    on_click = "${pkgs.pavucontrol}/bin/pavucontrol --tab=3"

    [[block]]
    block = "time"
    interval = 5
    format = "%a %d/%m %H:%M"
  '' + config.asdf.graphical.sway.status-configuration.extraConfig)
