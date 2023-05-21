{
  description = "hakanssn Nixos configuration";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url =
      "github:nix-community/impermanence"; # bind-mount directories

    # Extras
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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
      };
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , agenix
    , home-manager
    , impermanence
    , nur
    , emacs-overlay
    , hyprland
    , xdph
    , nixos-mailserver
    }:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      sharedModules =
        [
          ({ ... }: { nix.extraOptions = "experimental-features = nix-command flakes"; })
          ({ inputs, outputs, lib, config, pkgs, ... }: {
            nixpkgs = {
              overlays = [
                nur.overlay
                emacs-overlay.overlay
                (_: prev: {
                  xdg-desktop-portal-hyprland = inputs.xdph.packages.${prev.stdenv.hostPlatform.system}.default.override {
                    hyprland-share-picker = inputs.xdph.packages.${prev.stdenv.hostPlatform.system}.hyprland-share-picker.override { inherit hyprland; };
                  };
                })
              ];
            };
          })
          agenix.nixosModules.age
          impermanence.nixosModule
          nixos-mailserver.nixosModule

          home-manager.nixosModule
          { home-manager.sharedModules = [ hyprland.homeManagerModules.default ]; }

          ./modules
        ];
    in
    rec {
      devShells = forAllSystems
        (system:
          let pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = pkgs.mkShell {
              # Enable experimental features without having to specify the argument
              NIX_CONFIG = "experimental-features = nix-command flakes";
              nativeBuildInputs = [ pkgs.nix pkgs.home-manager pkgs.git pkgs.age ];
            };
          });
      nixosConfigurations = {
        falconia = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = sharedModules ++ [ ./machines/falconia/default.nix ];
        };
        gattsu = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = sharedModules ++ [ ./machines/gattsu/default.nix ];
        };
        rickert = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = sharedModules ++ [ ./machines/rickert/default.nix ];
        };
      };
      templates = import ./templates;
    };
}
