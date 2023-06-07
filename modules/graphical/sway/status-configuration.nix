{ config, lib, pkgs, ... }:
let
  mail-status = pkgs.writeShellScript "sway-mail-status" ''
    mails=$(${pkgs.mblaze}/bin/mlist -N $(${pkgs.mblaze}/bin/mdirs ~/mail) | ${pkgs.coreutils}/bin/wc -l)
    if [ "$mails" -gt 0 ]
    then
      echo "{ \"state\": \"Info\", \"text\": \"\uf0e0 $mails\" }"
    else
      echo "{ \"state\": \"Idle\", \"text\": \"\" }"
    fi
  '';
  org-clock-in-status = pkgs.writeShellScript "sway-org-clock-in-status" ''
    status=$(emacsclient --eval "(if (org-clock-is-active) (substring-no-properties (org-clock-get-clock-string)))" | tr -d '"')
    if [ "$status" = "nil" ]
    then
      echo "{ \"state\": \"Idle\", \"text\": \"\" }"
    else
      echo "{ \"state\": \"Info\", \"text\": \"$status\" }"
    fi
  '';
in
pkgs.writeText "configuration.toml" (""
  + (lib.optionalString config.hakanssn.core.emacs.enable ''
  [[block]]
  block = "custom"
  json = true
  command = "${org-clock-in-status}"
  interval = 5
  on_click = "emacsclient -n -c --eval \"(org-clock-goto)\""
  hide_when_empty = true
'')
  + (lib.optionalString config.hakanssn.graphical.laptop ''
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
  block = "github"
  hide_if_total_is_zero = true

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
'' + config.hakanssn.graphical.sway.status-configuration.extraConfig)
