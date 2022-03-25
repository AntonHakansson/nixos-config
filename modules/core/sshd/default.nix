{ config, lib, ... }:

{
  asdf.core.zfs = {
    ensureSystemExists = [ "${config.asdf.dataPrefix}/etc/ssh" ];
    ensureHomeExists = [ ".ssh" ];
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    hostKeys = [
      {
        bits = 4096;
        path = "${config.asdf.dataPrefix}/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "${config.asdf.dataPrefix}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
