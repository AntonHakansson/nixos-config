{ config, lib, pkgs, ... }: {

  options.hakanssn.graphical.plasma = {
    enable = lib.mkEnableOption "Plasma Desktop environment";
  };

  config = lib.mkIf config.hakanssn.graphical.plasma.enable {

    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    };

    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
      konsole
      oxygen
      elisa
      khelpcenter
    ];
  };
}
