{ ... }:

let
  base = {
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
    };
  };
in {
  home-manager.users.hakanssn = { ... }: base;
  home-manager.users.root = { ... }: base;
}
