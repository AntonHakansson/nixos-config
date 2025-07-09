{ config, lib, ... }:

{
  options.hakanssn.services.hakanssn-webserver.enable = lib.mkEnableOption "hakanssn webserver";

  config = lib.mkIf config.hakanssn.services.hakanssn-webserver.enable {
    services.hakanssn-webserver = {
      enable = true;
    };
    hakanssn.services.nginx.hosts = [{
      fqdn = "hakanssn.com";
      basicProxy = "http://localhost:8000";
    }];
  };
}
