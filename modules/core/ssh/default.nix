{ config, lib, pkgs, ... }:
{
  hakanssn.core.zfs.homeDataLinks = [{
    directory = ".ssh";
    mode = "0700";
  }];
  home-manager.users.hakanssn = { ... }: {
    programs.ssh.enable = true;
    home.packages =
      lib.mkIf config.hakanssn.graphical.enable [ pkgs.sshfs ];
  };

  hakanssn.core.zfs.systemDataLinks = [{
    directory = "/root/.ssh/";
    mode = "0700";
  }];
}
