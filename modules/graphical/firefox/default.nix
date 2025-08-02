{ config, lib, pkgs, ... }:

let
  ffPackage = pkgs.firefox-beta.override {
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
in
{
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
    hakanssn.core.nix.unfreePackages = [ "firefox-beta" "firefox-beta-unwrapped" ];

    home-manager.users.hakanssn = { ... }: {
      programs = {
        browserpass = {
          enable = true;
          browsers = [ "firefox" ];
        };
        firefox = {
          enable = true;
          package = ffPackage;
          profiles.hakanssn = {
            isDefault = true;
            extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
              browserpass
              darkreader
              vimium
              swedish-dictionary
              tree-style-tab
              decentraleyes
              i-dont-care-about-cookies
              ublock-origin
              leechblock-ng
            ];
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
              # Enable WebGL support
              "webgl.force-enabled" = true;

              "browser.aboutConfig.showWarning" = false;
              "browser.contentblocking.category" = "custom";
              "browser.download.dir" = "/home/hakanssn/downloads";
              "browser.shell.checkDefaultBrowser" = false;
              "browser.startup.homepage" = "about:blank";
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
