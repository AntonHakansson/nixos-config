{ ... }: {
  imports = [ ./hardware.nix ];

  networking.hostId = "06ad334e";

  asdf = {
    stateVersion = "21.11";
    core = {
      zfs = {
        encrypted = false;
        rootDataset = "rpool/local/root";
      };
    };
    development = {
      enable = true;
      git.email = "anton.hakansson98@gmail.com";
    };
  };
}
