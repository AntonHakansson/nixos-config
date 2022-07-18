{ config, lib, ... }: {
  imports = [ ./docker ./git ];

  options.hakanssn.development.enable = lib.mkEnableOption "development tools";

  config = lib.mkIf config.hakanssn.development.enable {
    hakanssn.development = {
      git.enable = lib.mkDefault true;
      docker.enable = lib.mkDefault true;
    };
  };
}
