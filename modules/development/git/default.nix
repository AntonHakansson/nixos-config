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
    lib.mkIf config.hakanssn.development.git.enable {
      home-manager.users.hakanssn = { ... }: {
        home.packages = with pkgs; [ gitAndTools.gitflow git-crypt ];
        programs.git = {
          enable = true;
          ignores = [ ".direnv" ".envrc" ];
          settings = {
            user.name = "Anton Hakansson";
            user.email = config.hakanssn.development.git.email;
            github.user = "AntonHakansson";

            lfs.enable = true;

            core.whitespace = "trailing-space";

            url."https://github.com/".insteadOf = "gh:";
            url."git@github.com:AntonHakansson/".insteadOf = "ah:";
            url."https://gitlab.com/".insteadOf = "gl:";
            url."https://gist.github.com/".insteadOf = "gist:";
            url."https://bitbucket.org/".insteadOf = "bb:";

            aliases = {
              # Reset
              unadd = "reset HEAD";
            };

            safe.directory = "/home/hakanssn/repos/nixos-config";
          };
        };
      };
    };
}
