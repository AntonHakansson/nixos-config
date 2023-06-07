{ config, lib, pkgs, ... }: {
  options.hakanssn.development.git = {
    enable = lib.mkOption {
      default = true;
      example = false;
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = "anton.hakansson98@gmail.com";
      description = "Default global git email";
    };
  };

  config =
    let
      base = {
        home.packages = with pkgs; [ gitAndTools.gitflow git-crypt ];
        programs.git = {
          enable = true;

          userEmail = config.hakanssn.development.git.email;
          userName = "Anton Hakansson";

          lfs.enable = true;

          extraConfig = {
            core = { whitespace = "trailing-space"; };
            github.user = "AntonHakansson";
            safe.directory = "/home/hakanssn/repos/nixos-config";

            # Aliases
            url."https://github.com/".insteadOf = "gh:";
            url."git@github.com:AntonHakansson/".insteadOf = "ah:";
            url."https://gitlab.com/".insteadOf = "gl:";
            url."https://gist.github.com/".insteadOf = "gist:";
            url."https://bitbucket.org/".insteadOf = "bb:";
          };
          aliases = {
            # Reset
            unadd = "reset HEAD";
          };
          ignores = [ ".direnv" ".envrc" ];
          # signing = {
          #   key = "anton@hakanssn.com";
          #   signByDefault = config.hakanssn.graphical.enable;
          # };
        };
      };
    in
    lib.mkIf config.hakanssn.development.git.enable {
      home-manager.users.hakanssn = { ... }: base;
      home-manager.users.root = { ... }: base;
    };
}
