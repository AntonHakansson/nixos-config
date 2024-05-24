{ config, lib, pkgs, ... }: {
  options.hakanssn.development.cc.enable = lib.mkEnableOption "Enable global C/C++ tools and common libraries";

  config = lib.mkIf config.hakanssn.development.enable {
    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ file man-pages man-pages-posix gdb clang-tools gnumake gf aflplusplus tinycc ];
      xdg.configFile."gdb/gdbinit".text = ''
        set host-charset UTF-8
        set target-charset UTF-8
        set target-wide-charset UTF-8

        set confirm off
        set print pretty on
        set disassembly-flavor intel

        set history save on
        set history filename ~/.cache/.gdb_history

        set auto-load local-gdbinit
      '';
      home.sessionVariables = {
        # debugger-oriented flags: break on error instead of uselessly exiting
        ASAN_OPTIONS = "abort_on_error=1:halt_on_error=1:detect_stack_use_after_return=1";
        UBSAN_OPTIONS = "abort_on_error=1:halt_on_error=1";
      };
    };
  };
}
