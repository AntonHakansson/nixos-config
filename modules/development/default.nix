{ config, lib, ... }: {
  imports = [ ./docker ./git ./cc ];

  options.hakanssn.development.enable = lib.mkEnableOption "development tools";

  config = lib.mkIf config.hakanssn.development.enable {
    hakanssn.development = {
      git.enable = lib.mkDefault true;
      docker.enable = lib.mkDefault true;
      cc.enable = lib.mkDefault true;
    };
  };
}
