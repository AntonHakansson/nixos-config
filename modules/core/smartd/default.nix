{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.smartmontools ];
  services.smartd = {
    enable = lib.mkDefault true;
    autodetect = true;
    notifications = {
      mail = {
        enable = true;
        sender = "postbot@hakanssn.com";
        recipient = "webmaster@hakanssn.com";
      };
    };
  };
}
