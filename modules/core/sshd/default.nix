{ config, lib, ... }:

{
  hakanssn.core.zfs = {
    ensureSystemExists = [ "${config.hakanssn.dataPrefix}/etc/ssh" ];
    ensureHomeExists = [ ".ssh" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
    hostKeys = [
      {
        bits = 4096;
        path = "${config.hakanssn.dataPrefix}/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "${config.hakanssn.dataPrefix}/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
  age.secrets."authorized_keys/root" = {
    file = ../../../secrets/authorized_keys/root.age;
    path = "/root/.ssh/authorized_keys";
    symlink = false;
  };
  age.secrets."authorized_keys/hakanssn" = {
    file = ../../../secrets/authorized_keys/hakanssn.age;
    owner = "hakanssn";
    path = "/home/hakanssn/.ssh/authorized_keys";
    symlink = false;
  };
}
