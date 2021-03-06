{ config, lib, pkgs, ... }:

{
  options.hakanssn.graphical.terminal.enable = lib.mkEnableOption "terminal";

  config = lib.mkIf config.hakanssn.graphical.terminal.enable {
    home-manager.users.hakanssn = { pkgs, ... }: {
      programs.kitty = {
        enable = true;
        settings = {
          enable_audio_bell = false;
          visual_bell_duration = "0.25";
          remember_window_size = false;
          confirm_os_window_close = 0;
        };
      };
    };
  };
}
