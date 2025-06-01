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

        # When a breakpoint it is hit, automatically pop reserved function frames (starting with __)
        if !$_isvoid($_any_caller_matches)
            define hook-stop
                while $_thread && $_any_caller_matches("^__")
                    up-silently
                end
            end
        end

        # Print array assuming array_count variable exists
        define parr
            if $argc == 1
                set $arr_name = "$arg0"
                set $count_name = "$arg0_count"
                # Check if variables exist
                if &$arg0 != 0
                    eval "print *%s@%s", $arr_name, $count_name
                else
                    printf "Error: Variable %s not found\n", $arr_name
                end
            else
                print "Usage: parr <array_name>"
            end
        end

        # Print stack with local variables
        define btfull
            set $frame = 0
            set $nframes = 8
            if $argc >= 1
                set $nframes = $arg0
            end
            while $frame < $nframes
                printf "\n=== Frame %d ===\n", $frame
                frame $frame
                info locals
                set $frame = $frame + 1
            end
            frame 0
        end

        # Print linked list (assuming node->next structure)
        define plist
            if $argc == 1
                set $node = $arg0
                set $count = 0
                while $node != 0 && $count < 20
                    printf "Node %d: ", $count
                    print *$node
                    set $node = $node->next
                    set $count = $count + 1
                end
            else
                print "Usage: plist <head_node>"
            end
        end
      '';
      home.sessionVariables = {
        # debugger-oriented flags: break on error instead of uselessly exiting
        ASAN_OPTIONS = "abort_on_error=1:halt_on_error=1:detect_stack_use_after_return=1";
        UBSAN_OPTIONS = "abort_on_error=1:halt_on_error=1";
      };
    };
  };
}
