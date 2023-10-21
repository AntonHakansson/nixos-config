{ config, lib, pkgs, ... }:

{
  options.hakanssn.core.emacs = {
    enable = lib.mkEnableOption "emacs";
    fullConfig = lib.mkOption {
      readOnly = true;
      default = builtins.readFile ./init.el + (lib.concatStringsSep "\n" config.hakanssn.core.emacs.extraConfig) + ''
        (provide 'init)
        ;;; init.el ends here
      '';
    };
    extraConfig = lib.mkOption {
      default = [ ];
    };
    package = lib.mkOption {
      readOnly = true;
      default = pkgs.emacsWithPackagesFromUsePackage {
        config = config.hakanssn.core.emacs.fullConfig;
        package = pkgs.emacs-pgtk;
        alwaysEnsure = true;
        extraEmacsPackages = epkgs: (lib.optional config.hakanssn.graphical.mail.enable pkgs.mu);
      };
    };
  };

  config = lib.mkIf config.hakanssn.core.emacs.enable {
    hakanssn.core.zfs.homeCacheLinks = [ ".cache/emacs" ];

    home-manager.users.hakanssn = { lib, ... }: {
      services.emacs = {
        enable = true;
        client.enable = true;
        socketActivation.enable = true;
        package = config.hakanssn.core.emacs.package;
      };
      programs.zsh.shellAliases = {
        e = "emacsclient -nw";
        ee = "emacsclient -c";
      };
      home = let
        aspell = (pkgs.aspellWithDicts (ds: with ds; [ en en-computers en-science sv ]));
      in {
        packages = with pkgs; [
          (pkgs.writeShellScriptBin "emacseditor" ''${config.hakanssn.core.emacs.package}/bin/emacs "$@"'')
          (pkgs.writeShellScriptBin "emacs" ''${config.hakanssn.core.emacs.package}/bin/emacs "$@"'')
          (pkgs.writeShellScriptBin "emacsclient" ''${config.hakanssn.core.emacs.package}/bin/emacsclient "$@"'')

          ## Core dependencies
          gcc
          binutils # native-comp needs 'as', provided by this
          git
          (ripgrep.override { withPCRE2 = true; })
          gnutls # for TLS connectivity

          ## Optional dependencies
          fd # faster projectile indexing
          imagemagick # for image-dired
          zstd # for undo-fu-session/undo-tree compression

          ## Module dependencies
          # :checkers spell
          aspell
          proselint
          nodePackages.textlint
          # :checkers grammar
          languagetool
          # :tools editorconfig
          editorconfig-core-c # per-project style config
          # :tools lookup & :lang org +roam
          sqlite

          # :lang latex & :lang org (latex previews)
          (texlive.combine {
            inherit (texlive)
              scheme-medium xifthen ifmtarg framed paralist titlesec wrapfig
              amsmath svg capt-of trimspaces catchfile transparent;
          })
          # hakanssn.leetcode-to-org TODO: fix broken leetcode-to-org package
          # :lang nix
          nil
        ];
        sessionVariables = {
          EDITOR = "emacsclient -nw";
          ASPELL_CONF = "dict-dir ${aspell}/lib/aspell";
        };
      };
      xdg.configFile = {
        "emacs/early-init.el".source = ./early-init.el;
        "emacs/init.el".text = config.hakanssn.core.emacs.fullConfig;
      };

      # org-capture setup
      xdg.dataFile."applications/emacs-capture.desktop" = {
        text = ''
          [Desktop Entry]
          Name=Org Capture
          Exec=${config.hakanssn.core.emacs.package}/bin/emacsclient %u
          Comment=Capture the web into org
          Type=Application
          Terminal=false
          MimeType=x-scheme-handler/org-protocol;
        '';
      };
      xdg.mimeApps.defaultApplications."x-scheme-handler/org-protocol" = "org-protocol.desktop";
      programs.firefox.profiles.hakanssn.settings."network.protocol-handler.external.org-protocol" = true;
      programs.firefox.profiles.hakanssn.bookmarks.org-capture = {
        name = "org-capture";
        url =
          "javascript:location.href ='org-protocol://roam-ref?template=r&ref=' + encodeURIComponent(location.href) + '&title=' + encodeURIComponent(document.title) + '&body=' + encodeURIComponent(window.getSelection())";
      };
    };
    fonts.packages = with pkgs; [
      emacs-all-the-icons-fonts
      iosevka-bin
      (iosevka-bin.override { variant = "aile"; })
    ];
  };
}
