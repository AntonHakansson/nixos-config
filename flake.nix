{
  description = "Nixos configuration";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url =
      "github:nix-community/impermanence"; # bind-mount directories

    # Extras
    doom-emacs = { url = "github:doomemacs/doomemacs"; flake = false; };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, agenix, home-manager, impermanence, nur
    , utils, doom-emacs, emacs-overlay, nixos-mailserver }:
    let customPackages = callPackage: { };
    in utils.lib.mkFlake {
      inherit self inputs;
      channels.nixpkgs = {
        input = nixpkgs;
        overlaysBuilder = _: [
          emacs-overlay.overlay
          (self: super: customPackages self.callPackage)
          nur.overlay
        ];
      };
      hostDefaults = {
        modules = [
          ({ lib, pkgs, ... }: {
            environment.etc = lib.mapAttrs' (key: val: {
              name = "channels/${key}";
              value = {
                source = pkgs.runCommandNoCC "${key}-channel" { } ''
                  mkdir $out
                  echo "${
                    val.rev or (toString val.lastModified)
                  }" > $out/.version-suffix
                  echo "import ${val.outPath}/default.nix" > $out/default.nix
                '';
              };
            }) inputs;
            nix.nixPath = [ "/etc/channels" ];
          })
          agenix.nixosModules.age
          home-manager.nixosModule
          impermanence.nixosModule
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
          packages = customPackages pkgs.callPackage;
          devShell = pkgs.mkShell {
            buildInputs = [
              pkgs.nixpkgs-fmt
              agenix.defaultPackage.x86_64-linux
              pkgs.cachix
            ];
          };
        };
    };
}
