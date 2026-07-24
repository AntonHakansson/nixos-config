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
    hakanssn.core.zfs.homeDataLinks = [ ".config/mozilla" ];
    hakanssn.core.nix.unfreePackages = [ "firefox-beta" "firefox-beta-unwrapped" ];

    home-manager.users.hakanssn = { config, ... }: {
      programs = {
        browserpass = {
          enable = true;
          browsers = [ "firefox" ];
        };
        firefox = {
          enable = true;
          package = ffPackage;
          configPath = "${config.xdg.configHome}/mozilla/firefox";
          profiles.hakanssn = {
            isDefault = true;
            extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
              browserpass
              i-dont-care-about-cookies
              leechblock-ng
              swedish-dictionary
              ublock-origin
              vimium
            ];
            settings = {
              # Resume the previous browser session
              "browser.startup.page" = 3;
              # Don't hide tabs/toolbar in fullscreen
              "browser.fullscreen.autohide" = false;
              # Enable WebGL support
              "webgl.force-enabled" = true;

              "browser.aboutConfig.showWarning" = false;
              "browser.contentblocking.category" = "custom";
              "browser.shell.checkDefaultBrowser" = false;
              "browser.startup.homepage" = "about:blank";
              "sidebar.verticalTabs" = true;
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
