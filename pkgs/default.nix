{ pkgs, ... }: {
  hakanssn = {
    leetcode-to-org = pkgs.callPackage ./leetcode-to-org { };
    iosvmata = pkgs.callPackage ./iosvmata.nix { };
  };
}
