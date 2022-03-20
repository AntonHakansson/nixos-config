{ config, pkgs, ... }: {
  config = {
    programs.neovim = {
      enable = true;
      viAlias = true;
    };
  };
}
