{ config, pkgs, ... }:
let
  base = user: {
    programs.zsh.shellAliases = {
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
    };
  };
in {
  config = {
    programs.neovim = { enable = true; };
    home-manager.users.root = { ... }: (base "root");
    home-manager.users.hakanssn = { ... }: (base "hakanssn");
  };
}
