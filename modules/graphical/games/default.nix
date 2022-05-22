{ config, lib, pkgs, ... }:

{
  options.asdf.graphical.games.enable =
    lib.mkEnableOption "Enable game launchers";

  config = lib.mkIf config.asdf.graphical.games.enable {
    programs.steam.enable = true;
    asdf.core.nix.unfreePackages = [ "steam" "steam-original" "steam-runtime" ];
  };
}
