{ config, inputs, lib, pkgs, ... }:

{
  options.hakanssn.core.emacs = {
    enable = lib.mkEnableOption "emacs";
    doomEmacsRevision = lib.mkOption { default = inputs.doom-emacs.rev; };
    package = lib.mkOption {
      readOnly = true;
      default = ((pkgs.emacsPackagesFor pkgs.emacsPgtkNativeComp).emacsWithPackages
        (epkgs: with epkgs; [ vterm pdf-tools ]));
    };
  };

  config = let
    EMACSDIR = "${config.home-manager.users.hakanssn.xdg.configHome}/emacs";
    DOOMDIR = "${config.home-manager.users.hakanssn.xdg.configHome}/doom";
    DOOMLOCALDIR = "${config.home-manager.users.hakanssn.xdg.dataHome}/doom";
    tangledPrivateDir = pkgs.runCommand "tangled-doom-private" { } ''
      mkdir -p $out
      cp ${./config.org} $out/config.org
      cd $out
      ${config.hakanssn.core.emacs.package}/bin/emacs --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "./config.org")'
      rm $out/config.org
    '';
    emacsDaemonScript = pkgs.writeScript "emacs-daemon" ''
      #!${pkgs.zsh}/bin/zsh -l
      if [ ! -d ${EMACSDIR}/.git ]; then
        mkdir -p ${EMACSDIR}
        git -C ${EMACSDIR} init
      fi
      if [ $(git -C ${EMACSDIR} rev-parse HEAD) != ${config.hakanssn.core.emacs.doomEmacsRevision} ]; then
        git -C ${EMACSDIR} fetch https://github.com/doomemacs/doomemacs.git || true
        git -C ${EMACSDIR} checkout ${config.hakanssn.core.emacs.doomEmacsRevision} || true
        ${EMACSDIR}/bin/doom sync || true
      fi
      exec ${config.hakanssn.core.emacs.package}/bin/emacs --daemon
    '';
  in lib.mkIf config.hakanssn.core.emacs.enable {
    hakanssn.core.zfs.homeCacheLinks = [ ".config/emacs" ".local/share/doom" ];

    home-manager.users.hakanssn = { lib, ... }: {
      home = {
        packages = with pkgs; [
          config.hakanssn.core.emacs.package

          gcc
          binutils # native-comp needs 'as', provided by this

          ## Doom dependencies
          git
          (ripgrep.override { withPCRE2 = true; })
          gnutls # for TLS connectivity

          ## Optional dependencies
          fd # faster projectile indexing
          imagemagick # for image-dired
          # (lib.mkIf (config.programs.gpg.enable)
          #   pinentry_emacs) # in-emacs gnupg prompts
          zstd # for undo-fu-session/undo-tree compression

          ## Module dependencies
          # :checkers spell
          (aspellWithDicts (ds: with ds; [ en en-computers en-science sv ]))
          proselint
          nodePackages.textlint
          # :checkers grammar
          languagetool
          # :tools editorconfig
          editorconfig-core-c # per-project style config
          # :tools lookup & :lang org +roam
          sqlite

          # :lang nix
          nixfmt
          # :lang sh
          shellcheck
          shfmt
          # :lang cc
          ccls
          # :lang latex & :lang org (latex previews)
          (texlive.combine {
            inherit (texlive)
              scheme-medium xifthen ifmtarg framed paralist titlesec wrapfig
              amsmath svg capt-of trimspaces catchfile transparent;
          })
          # :lang rust
          rustfmt
          rust-analyzer
          # :lang markdown
          pandoc
          # :lang org
          graphviz
          gnuplot
          maxima
          sage
        ];
        sessionPath = [ "${EMACSDIR}/bin" ];
        sessionVariables = {
          inherit EMACSDIR DOOMDIR DOOMLOCALDIR;
          EDITOR = "emacs";
        };
      };
      systemd.user.services.emacs-daemon = {
        Install.WantedBy = [ "default.target" ];
        Service = {
          Type = "forking";
          TimeoutStartSec = "10min";
          Restart = "always";
          ExecStart = toString emacsDaemonScript;
        };
      };
      xdg.configFile."doom/" = {
        source = "${tangledPrivateDir}/";
        recursive = true;
      };
    };
    fonts.fonts = with pkgs; [
      emacs-all-the-icons-fonts
      iosevka-bin
      (iosevka-bin.override { variant = "aile"; })
    ];
  };
}
