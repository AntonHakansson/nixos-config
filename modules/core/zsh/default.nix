{ config, lib, pkgs, ... }:

let
  base = (home: {
    home.packages = [ pkgs.autojump ];
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      autocd = true;
      dotDir = ".config/zsh";
      history = {
        expireDuplicatesFirst = true;
        path = "${config.hakanssn.cachePrefix}${home}/.local/share/zsh/history";
      };
      initExtra = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [
          "autojump"
          "common-aliases"
          "extract"
          "fzf"
          "git"
          "history-substring-search"
          "systemd"
          "tmux"
          "vi-mode"
        ];
        theme = "robbyrussell";
      };
      plugins = [{
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
        };
      }];
      sessionVariables = { DEFAULT_USER = "hakanssn"; };
      shellAliases = {
        g = "git";

        # grep
        grep = "rg";
        gi = "grep -i";

        # internet ip
        myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

        # nix
        nepl = "nix repl '<nixpkgs>'";
        ns = "nix search --no-update-lock-file";
        srch = "ns nixos";
        orch = "ns override";
        mn = ''
          manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | sk --preview="manix '{}'" | xargs manix
        '';

        # top
        top = "btm";

        # systemd
        stl = " systemctl";
        jtl = "journalctl";
        utl = "systemctl --user";
      };
    };
  });
in {
  programs.zsh.enable = true;
  hakanssn.core.zfs.systemCacheLinks = [ "/root/.local/share/autojump" ];
  hakanssn.core.zfs.homeCacheLinks = [ ".local/share/autojump" ];
  home-manager.users.hakanssn = { ... }: (base "/home/hakanssn");
  home-manager.users.root = { ... }: (base "/root");
}
