{ config, lib, ... }: {
  options.hakanssn.core.network.enable = lib.mkEnableOption "wireless";

  config = lib.mkIf config.hakanssn.core.network.enable {
    networking.wireless = {
      enable = true;
      environmentFile = config.age.secrets."passwords/networks.age".path;
      networks = { "batman-7288-5GHz" = { psk = "@PSK_batman@"; }; };
    };

    age.secrets."passwords/networks.age" = {
      file = ../../../secrets/passwords/network.age;
    };
  };
}
