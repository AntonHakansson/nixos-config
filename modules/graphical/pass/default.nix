{ config, lib, ... }:

{
  options.asdf.graphical.pass.enable = lib.mkEnableOption "passwordstore";

  config = lib.mkIf config.asdf.graphical.pass.enable {
    nixpkgs.overlays = [
      (self: super: {
        pass =
          (super.pass.override { pass = super.pass-wayland; }).withExtensions
          (ext: [ ext.pass-otp ]);
      })
    ];

    home-manager.users.hakanssn = { ... }: {
      programs.password-store = {
        enable = true;
        settings = { PASSWORD_STORE_DIR = "/home/hakanssn/repos/pass"; };
      };
      services.password-store-sync.enable = true;
    };
  };
}
