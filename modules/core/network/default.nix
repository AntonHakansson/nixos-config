{ config, lib, ... }: {
  options.hakanssn.core.network.enable = lib.mkEnableOption "wireless";

  config = lib.mkIf config.hakanssn.core.network.enable {
    networking.wireless = {
      enable = true;
      environmentFile = config.age.secrets."passwords/networks.age".path;
      networks = {
        "batman" = { psk = "@PSK_batman@"; };
        "TeliaGateway9C-97-26-91-52-01" = { psk = "@PSK_parents@"; };
      };
    };

    age.secrets."passwords/networks.age" = {
      file = ../../../secrets/passwords/network.age;
    };
  };
}
