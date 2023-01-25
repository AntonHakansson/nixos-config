{ config, lib, pkgs, ... }:

let
  ff2mpv-host = pkgs.stdenv.mkDerivation rec {
    pname = "ff2mpv";
    version = "4.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "woodruffw";
      repo = "ff2mpv";
      rev = "v${version}";
      sha256 = "sxUp/JlmnYW2sPDpIO2/q40cVJBVDveJvbQMT70yjP4=";
    };
    buildInputs = [ pkgs.python3 ];
    buildPhase = ''
      sed -i "s#/home/william/scripts/ff2mpv#$out/bin/ff2mpv.py#" ff2mpv.json
      # sed -i 's#"mpv"#"${pkgs.mpv}/bin/umpv"#' ff2mpv.py
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp ff2mpv.py $out/bin
      mkdir -p $out/lib/mozilla/native-messaging-hosts
      cp ff2mpv.json $out/lib/mozilla/native-messaging-hosts
    '';
  };
  ffPackage = pkgs.firefox.override {
    extraNativeMessagingHosts = [ ff2mpv-host ];
    extraPolicies = {
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFirefoxAccounts = true;
      FirefoxHome = {
        Pocket = false;
        Snippets = false;
      };
      OfferToSaveLogins = false;
      UserMessaging = {
        SkipOnboarding = true;
        ExtensionRecommendations = false;
      };
    };
  };
in {
  options.hakanssn.graphical.firefox = {
    enable = lib.mkEnableOption "firefox";
    package = lib.mkOption {
      description = "Final used firefox package";
      default = ffPackage;
      readOnly = true;
    };
  };

  config = lib.mkIf config.hakanssn.graphical.firefox.enable {
    hakanssn.core.zfs.homeCacheLinks = [ ".cache/mozilla" ];
    hakanssn.core.zfs.homeDataLinks = [ ".mozilla" ];

    home-manager.users.hakanssn = { ... }: {
      programs = {
        browserpass = {
          enable = true;
          browsers = [ "firefox" ];
        };
        firefox = {
          enable = true;
          package = ffPackage;
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            browserpass
            darkreader
            ff2mpv
            vimium
            swedish-dictionary
            tree-style-tab
            bypass-paywalls-clean
            decentraleyes
            i-dont-care-about-cookies
            ublock-origin
            leechblock-ng
          ];
          profiles.hakanssn = {
            isDefault = true;
            # Hide tabs and navbar
            userChrome = ''
              #TabsToolbar { visibility: collapse !important; }
              /* hide navigation bar when it is not focused; use Ctrl+L to get focus */
              #main-window:not([customizing]) #navigator-toolbox:not(:focus-within):not(:hover) {
                margin-top: -45px;
              }
              #navigator-toolbox {
                transition: 0.2s margin-top ease-out;
              }
            '';
            settings = {
              "devtools.theme" = "dark";
              # look for userChrome.css
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              # Resume the previous browser session
              "browser.startup.page" = 3;
              # Don't hide tabs/toolbar in fullscreen
              "browser.fullscreen.autohide" = false;

              "browser.aboutConfig.showWarning" = false;
              "browser.contentblocking.category" = "custom";
              "browser.download.dir" = "/home/hakanssn/downloads";
              "browser.newtabpage.enabled" = false;
              "browser.safebrowsing.malware.enabled" = false;
              "browser.safebrowsing.phishing.enabled" = false;
              "browser.shell.checkDefaultBrowser" = false;
              "browser.startup.homepage" = "about:blank";
              "dom.security.https_only_mode_pbm" = true;
              "network.cookie.cookieBehavior" = 1;
              "privacy.annotate_channels.strict_list.enabled" = true;
              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true;
              "security.identityblock.show_extended_validation" = true;
            };
            bookmarks = {
              wikipedia.url =
                "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
              nixpkgs.url =
                "https://search.nixos.org/options?channel=unstable&type=packages&query=%s";
              nur.url = "https://nur.nix-community.org/";
              nixos-discourse.url = "https://discourse.nixos.org/";
              home-manager.url =
                "https://rycee.gitlab.io/home-manager/options.html";
            };
          };
        };
      };
    };
  };
}
