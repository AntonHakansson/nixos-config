{ config, lib, ... }: {
  imports = [ ./git ];

  options.asdf.development.enable = lib.mkEnableOption "development tools";

  config = lib.mkIf config.asdf.development.enable {
    asdf.development.git.enable = true;
  };
}
