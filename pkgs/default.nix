{ pkgs, ... }: {
  hakanssn = {
    leetcode-to-org = pkgs.callPackage ./leetcode-to-org { };
    iosvmata = pkgs.callPackage ./iosvmata.nix { };
    yt-dlp-from-clipboard = pkgs.callPackage ./yt-dlp-from-clipboard.nix { };
  };
}
