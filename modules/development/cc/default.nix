{ config, lib, pkgs, ... }: {
  options.hakanssn.development.cc.enable = lib.mkEnableOption "Enable global C/C++ tools and common libraries";

  config = lib.mkIf config.hakanssn.development.enable {
    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ gdb clang-tools gf aflplusplus tinycc ];
    };
  };
}
