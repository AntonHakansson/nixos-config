{ config, lib, pkgs, ... }:
let
  ssh_wrapper = pkgs.symlinkJoin {
    name = "ssh";
    paths = [
      (pkgs.writeShellScriptBin "ssh" ''
        export TERM=xterm-256color
        ${pkgs.openssh}/bin/ssh $@
      '')
      pkgs.openssh
    ];
  };
  base = home: user: {
    programs.ssh = {
      enable = true;
      userKnownHostsFile = "${config.asdf.cachePrefix}${home}/.ssh/known_hosts";
      extraOptionOverrides = {
        IdentityFile = "${config.asdf.dataPrefix}${home}/.ssh/id_ed25519";
      };
    };
    home.packages =
      lib.mkIf config.asdf.graphical.enable [ ssh_wrapper pkgs.sshfs ];
  };
in {
  home-manager.users.root = { ... }: (base "/root" "root");
  home-manager.users.hakanssn = { ... }: (base "/home/hakanssn" "hakanssn");
}
