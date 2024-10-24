{ config, lib, ... }: {
  options.hakanssn.core.network.enable = lib.mkEnableOption "wireless";

  config = lib.mkIf config.hakanssn.core.network.enable {
    networking.wireless = {
      enable = !config.networking.networkmanager.enable;
      userControlled.enable = true;
      secretsFile = config.age.secrets."passwords/networks.age".path;
      networks = {
        "batman" = { pskRaw = "ext:PSK_batman"; };
        "#Telia-523728" = { pskRaw = "ext:PSK_parents"; };
        "#Telia-523728-2.4Ghz" = { pskRaw = "ext:PSK_parents"; };
      };
    };
    age.secrets."passwords/networks.age" = {
      file = ../../../secrets/passwords/network.age;
    };

    hakanssn.core.zfs.systemCacheLinks = [ "/etc/NetworkManager/system-connections" ];
    networking.networkmanager = {
      enable = true;
    };
  };
}
