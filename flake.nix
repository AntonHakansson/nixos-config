{
  description = "Nixos configuration";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    flake-utils.url = "github:numtide/flake-utils";
    utils = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs = {
        flake-utils.follows = "flake-utils";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url =
      "github:nix-community/impermanence"; # bind-mount directories
    devshell = {
      url = "github:numtide/devshell";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Extras
    doom-emacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xdph = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , agenix
    , home-manager
    , devshell
    , impermanence
    , nur
    , flake-utils
    , utils
    , doom-emacs
    , emacs-overlay
    , hyprland
    , xdph
    , nixos-mailserver
    }:
    utils.lib.mkFlake {
      inherit self inputs;
      channels.nixpkgs = {
        input = nixpkgs;
        overlaysBuilder = _: [
          devshell.overlay
          nur.overlay
          emacs-overlay.overlay
          (_: prev: {
            xdg-desktop-portal-hyprland = inputs.xdph.packages.${prev.stdenv.hostPlatform.system}.default.override {
              hyprland-share-picker = inputs.xdph.packages.${prev.stdenv.hostPlatform.system}.hyprland-share-picker.override { inherit hyprland; };
            };
          })
        ];
      };
      hostDefaults = {
        modules = [
          { nix.generateRegistryFromInputs = true; }
          agenix.nixosModules.age
          home-manager.nixosModule
          impermanence.nixosModule
          { home-manager.sharedModules = [ hyprland.homeManagerModules.default ]; }
          nixos-mailserver.nixosModule
          ./modules
        ];
      };
      hosts = {
        falconia.modules = [ ./machines/falconia ];
        gattsu.modules = [ ./machines/gattsu ];
        rickert.modules = [ ./machines/rickert ];
      };
      outputsBuilder = channels:
        let pkgs = channels.nixpkgs;
        in {
          devShells = rec {
            nixos-config = pkgs.devshell.mkShell {
              name = "hakanssn NixOS config";
              packages = [
                pkgs.nixpkgs-fmt
                (pkgs.writeShellScriptBin "fetchpatch"
                  "curl -L https://github.com/NixOS/nixpkgs/pull/$1.patch -o patches/$1.patch")
                agenix.defaultPackage.x86_64-linux
                pkgs.cachix
              ];
            };
            default = nixos-config;
          };
        };
      templates = import ./templates;
    };
}
