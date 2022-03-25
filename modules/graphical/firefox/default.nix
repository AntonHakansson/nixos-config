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
      sed -i 's#"mpv"#"${pkgs.mpv}/bin/umpv"#' ff2mpv.py
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
    pkcs11Modules = [ pkgs.eid-mw ];
    forceWayland = true;
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
  zotero-connector =
    pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon rec {
      pname = "zotero-connector";
      version = "5.0.92";
      addonId = "zotero@chnm.gmu.edu";
      url =
        "https://download.zotero.org/connector/firefox/release/Zotero_Connector-${version}.xpi";
      sha256 = "DfaDjjgJiSGJ0q9ScStAVRN3IcH8HY30K7IssuHZi2A=";
      meta = with lib; {
        homepage = "https://www.zotero.org";
        description = "Save references to Zotero from your web browser";
        license = licenses.agpl3;
        platforms = platforms.all;
      };
    };
in {
  options.asdf.graphical.firefox = {
    enable = lib.mkEnableOption "firefox";
    package = lib.mkOption {
      description = "Final used firefox package";
      default = ffPackage;
      readOnly = true;
    };
  };

  config = lib.mkIf config.asdf.graphical.firefox.enable {
    asdf.core.zfs.homeCacheLinks = [ ".cache/mozilla" ];
    asdf.core.zfs.homeDataLinks = [ ".mozilla" ];

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
            bitwarden
            browserpass
            ff2mpv
            zotero-connector
            umatrix

            darkreader
            vimium

            decentraleyes
            https-everywhere
            ublock-origin
            i-dont-care-about-cookies
          ];
          profiles.hakanssn = {
            id = 0;
            userChrome = builtins.readFile ./userChrome.css;
            settings = {
              "devtools.theme" = "dark";
              "toolkit.legacyUserProfileCustomizations.stylesheets" =
                true; # look for userChrome.css

              "browser.aboutConfig.showWarning" = false;
              "browser.contentblocking.category" = "custom";
              "browser.download.dir" = "/home/hakanssn/downloads";
              "browser.newtabpage.enabled" = false;
              "browser.safebrowsing.malware.enabled" = false;
              "browser.safebrowsing.phishing.enabled" = false;
              "browser.shell.checkDefaultBrowser" = false;
              "browser.startup.homepage" = "about:blank";
              "browser.startup.page" = 3; # Resume the previous browser session
              "browser.fullscreen.autohide" =
                false; # Don't hide tabs/toolbar in fullscreen
              "dom.security.https_only_mode_pbm" = true;
              "network.cookie.cookieBehavior" = 1;
              "privacy.annotate_channels.strict_list.enabled" = true;
              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true;
              "security.identityblock.show_extended_validation" = true;
            };
          };
        };
      };
    };
  };
}
