{ config, lib, ... }: {
  imports = [ ./docker ./git ];

  options.asdf.development.enable = lib.mkEnableOption "development tools";

  config = lib.mkIf config.asdf.development.enable {
    asdf.development = {
      git.enable = lib.mkDefault true;
      docker.enable = lib.mkDefault true;
    };
  };
}
