{ config, lib, ... }:

{
  options.hakanssn.graphical.pass.enable = lib.mkEnableOption "passwordstore";

  config = lib.mkIf config.hakanssn.graphical.pass.enable {
    nixpkgs.overlays = [
      (self: super: {
        pass = (super.pass.override { pass = super.pass-wayland; });
      })
    ];

    home-manager.users.hakanssn = { ... }: {
      programs.password-store = {
        enable = true;
        settings = { PASSWORD_STORE_DIR = "/home/hakanssn/repos/pass"; };
      };
      services.git-sync = {
        enable = true;
        repositories = {
          "password-store" = {
            uri = "git@github.com:AntonHakansson/pass.git";
            path = "/home/hakanssn/repos/pass";
          };
        };
      };
    };
  };
}
