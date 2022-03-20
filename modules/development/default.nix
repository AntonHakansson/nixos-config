{ config, lib, ... }: {
  imports = [ ./git ];

  options.asdf.development.enable = lib.mkOption { default = false; };

  config = lib.mkIf config.asdf.development.enable {
    asdf.development.git.enable = true;
  };
}
