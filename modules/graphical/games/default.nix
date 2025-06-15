{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.games.enable =
    lib.mkEnableOption "Enable game launchers";

  config = lib.mkIf config.hakanssn.graphical.games.enable {
    hakanssn.core.zfs.homeCacheLinks = [ ".local/share/Steam" ];
    programs.steam.enable = true;
    hakanssn.core.nix.unfreePackages = [ "steam" "steam-original" "steam-run" "steam-unwrapped" ];
  };
}
