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
        package = pkgs.emacs-git-pgtk.overrideAttrs (old: {
          passthru = old.passthru // {
            treeSitter = true;
          };
        });
        alwaysEnsure = true;
        extraEmacsPackages = epkgs:
          (lib.optional config.hakanssn.graphical.mail.enable epkgs.mu4e) ++
          [ epkgs.treesit-grammars.with-all-grammars ];
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
      home = {
        packages = with pkgs; [
          (pkgs.writeShellScriptBin "emacseditor" ''${config.hakanssn.core.emacs.package}/bin/emacs "$@"'')
          (pkgs.writeShellScriptBin "emacs" ''${config.hakanssn.core.emacs.package}/bin/emacs "$@"'')
          (pkgs.writeShellScriptBin "emacsclient" ''${config.hakanssn.core.emacs.package}/bin/emacsclient "$@"'')

          ## Core dependencies
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
          hunspellDicts.en_US
          vale
          valeStyles.google
          valeStyles.write-good
          valeStyles.proselint
          # :tools editorconfig
          editorconfig-core-c # per-project style config
          # :tools lookup & :lang org +roam
          sqlite
          pandoc
          # :tools ai
          tgpt

          # :lang latex & :lang org (latex previews)
          (texlive.combine {
            inherit (texlive)
              scheme-medium xifthen ifmtarg framed paralist titlesec wrapfig
              amsmath svg capt-of trimspaces catchfile transparent;
          })
          # hakanssn.leetcode-to-org TODO: fix broken leetcode-to-org package
          # :lang nix
          nil
          # :lang c-mode
          universal-ctags
        ];
        sessionVariables = {
          EDITOR = "emacsclient -nw";
        };
      };
      xdg.configFile = {
        "emacs/early-init.el".source = ./early-init.el;
        "emacs/init.el".text = config.hakanssn.core.emacs.fullConfig;
      };

      # org-capture setup
      xdg.dataFile."applications/org-protocol.desktop" = {
        text = ''
        [Desktop Entry]
        Name=org-protocol
        Exec=emacsclient %u
        Type=Application
        Terminal=false
        Categories=System;
        MimeType=x-scheme-handler/org-protocol;
        '';
      };
      xdg.mimeApps.associations.added."x-scheme-handler/org-protocol" = "org-protocol.desktop";
      xdg.mimeApps.defaultApplications."x-scheme-handler/org-protocol" = "org-protocol.desktop";
      programs.firefox.profiles.hakanssn.settings."network.protocol-handler.external.org-protocol" = true;
      programs.firefox.profiles.hakanssn.bookmarks.org-capture = {
        name = "org-capture";
        url = ''
            javascript:location.href='org-protocol://capture?' +
              new URLSearchParams({
                    template: 'w',
                    url: window.location.href,
                    title: document.title,
                    body: function () {
                          var html = "";
                          if (typeof document.getSelection != "undefined") {
                             var sel = document.getSelection();
                             if (sel.rangeCount) {
                                var container = document.createElement("div");
                                for (var i = 0, len = sel.rangeCount; i < len; ++i) {
                                    container.appendChild(sel.getRangeAt(i).cloneContents());
                                }
                                html = container.innerHTML;
                             }
                          }
                          else if (typeof document.selection != "undefined") {
                              if (document.selection.type == "Text") {
                                  html = document.selection.createRange().htmlText;
                              }
                          }
                          var relToAbs = function (href) {
                              var a = document.createElement("a");
                              a.href = href;
                              var abs = a.protocol + "//" + a.host + a.pathname + a.search + a.hash;
                              a.remove();
                              return abs;
                          };
                          var elementTypes = [['a', 'href'], ['img', 'src']];
                          var div = document.createElement('div');
                          div.innerHTML = html;
                          elementTypes.map(function(elementType) {
                              var elements = div.getElementsByTagName(elementType[0]);
                              for (var i = 0; i < elements.length; i++) {
                                  elements[i].setAttribute(elementType[1], relToAbs(elements[i].getAttribute(elementType[1])));
                              }
                          });
                          return div.innerHTML;
                    }(),
              });
        '';
      };
      programs.firefox.profiles.hakanssn.bookmarks.codechef-capture = {
        name = "capture codechef problem";
        url = ''
            javascript:location.href='org-protocol://capture?' +
              new URLSearchParams({
                    template: 'w',
                    url: window.location.href,
                    title: function () {
                      var problem_title = document.getElementById("problem-statement").getElementsByTagName("h2")[0].innerText;
                      return "Codechef: " + problem_title;
                    }(),
                    body: function () {
                          var html = document.getElementById("problem-statement").innerHTML;
                          var relToAbs = function (href) {
                              var a = document.createElement("a");
                              a.href = href;
                              var abs = a.protocol + "//" + a.host + a.pathname + a.search + a.hash;
                              a.remove();
                              return abs;
                          };
                          var elementTypes = [['a', 'href'], ['img', 'src']];
                          var div = document.createElement('div');
                          div.innerHTML = html;
                          elementTypes.map(function(elementType) {
                              var elements = div.getElementsByTagName(elementType[0]);
                              for (var i = 0; i < elements.length; i++) {
                                  elements[i].setAttribute(elementType[1], relToAbs(elements[i].getAttribute(elementType[1])));
                              }
                          });

                          var remove_katex = div.getElementsByClassName("katex-html");
                          while(remove_katex.length > 0) {
                             remove_katex[0].parentNode.removeChild(remove_katex[0]);
                          }

                          return div.innerHTML;
                    }(),
              });
        '';
      };
    };
    fonts.packages = with pkgs; [
      iosevka-bin
      (iosevka-bin.override { variant = "Aile"; })
      hakanssn.iosvmata
      nerd-fonts.symbols-only
    ];
  };
}
