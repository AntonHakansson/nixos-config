{ config, lib, pkgs, ... }:

{
  options.asdf.graphical.xdg.enable = lib.mkOption {
    default = false;
    example = true;
  };

  config = lib.mkIf config.asdf.graphical.xdg.enable {
    asdf.core.zfs.homeDataLinks =
      [ "documents" "music" "pictures" "videos" ];
    asdf.core.zfs.homeCacheLinks = [ "downloads" "repos" ];

    home-manager.users.hakanssn = { pkgs, ... }: {
      home.packages = with pkgs; [ xdg-user-dirs xdg_utils ];
      xdg = {
        enable = true;
        # Some applications overwrite mimeapps.list with an identical file
        configFile."mimeapps.list".force = true;
        mimeApps = {
          enable = true;
          defaultApplications = {
            "image/png" = [ "org.kde.okular.desktop" ];
            "image/jpg" = [ "org.kde.okular.desktop" ];
            "image/jpeg" = [ "org.kde.okular.desktop" ];
            "application/pdf" = [ "org.kde.okular.desktop" ];

            "text/html" = [ "firefox.desktop" ];
            "x-scheme-handler/about" = [ "firefox.desktop" ];
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
            "x-scheme-handler/unknown" = [ "firefox.desktop" ];

            "x-scheme-handler/msteams" = [ "teams.desktop" ];
          };
        };
        userDirs = {
          enable = true;
          desktop = "$HOME/desktop";
          documents = "$HOME/documents";
          download = "$HOME/downloads";
          music = "$HOME/music";
          pictures = "$HOME/pictures";
          publicShare = "$HOME/desktop";
          templates = "$HOME/templates";
          videos = "$HOME/videos";
        };
      };
    };
  };
}
