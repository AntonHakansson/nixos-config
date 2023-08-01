{ pkgs, ... }: {
  hakanssn = {
    leetcode-to-org = pkgs.callPackage ./leetcode-to-org { };
  };
}
