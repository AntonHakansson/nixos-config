{
  description = "hakanssn Nixos configuration";

  inputs = {
    # Core
    nixpkgs.url        = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
    };
    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    hakanssn-webserver = {
      url = "github:AntonHakansson/hakanssn.com";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , agenix
    , home-manager
    , impermanence
    , nur
    , emacs-overlay
    , nixos-mailserver
    , hakanssn-webserver
    , ...
    }@inputs:
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
                (import ./overlays { inherit inputs; }).additions
                (import ./overlays { inherit inputs; }).modifications
                nur.overlays.default
                emacs-overlay.overlay
              ];
            };
          })
          agenix.nixosModules.age
          impermanence.nixosModule
          nixos-mailserver.nixosModule
          hakanssn-webserver.nixosModules.default

          home-manager.nixosModules.home-manager

          ./modules
        ];
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in import ./pkgs { inherit pkgs; });
      devShells = forAllSystems
        (system:
          let pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = pkgs.mkShell {
              # Enable experimental features without having to specify the argument
              NIX_CONFIG = "experimental-features = nix-command flakes";
              nativeBuildInputs = [ pkgs.nix pkgs.home-manager pkgs.git agenix.packages.x86_64-linux.default ]; 
            };
          });
      formatter = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in pkgs.nixpkgs-fmt);
      overlays = import ./overlays { inherit inputs; };
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
