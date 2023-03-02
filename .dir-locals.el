;;; Directory Local Variables            -*- no-byte-compile: t -*-
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((projectile-project-compilation-cmd . "doas nixos-rebuild switch --flake .")
         (projectile-project-run-cmd . "doas nixos-rebuild test --flake . --fast")
         (projectile-project-test-cmd . "nix flake check")
         (compile-command . "doas nixos-rebuild test --flake .")))
  )
