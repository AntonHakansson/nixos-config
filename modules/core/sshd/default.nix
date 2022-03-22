{ config, lib, ... }:

{
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    # hostKeys = [
    #   { bits = 4096; path = "${config.chvp.dataPrefix}/etc/ssh/ssh_host_rsa_key"; type = "rsa"; }
    #   { path = "${config.chvp.dataPrefix}/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
    # ];
  };
}
