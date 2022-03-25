{ config, lib, pkgs, ... }:
let
  base = home: user: {
    programs.ssh = {
      enable = true;
      userKnownHostsFile = "${config.asdf.cachePrefix}${home}/.ssh/known_hosts";
      extraOptionOverrides = {
        IdentityFile = "${config.asdf.dataPrefix}${home}/.ssh/id_ed25519";
      };
    };
    home.packages = lib.mkIf config.asdf.graphical.enable [ pkgs.sshfs ];
  };
in {
  home-manager.users.root = { ... }: (base "/root" "root");
  home-manager.users.hakanssn = { ... }: (base "/home/hakanssn" "hakanssn");
}
