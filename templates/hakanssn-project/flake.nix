{
  description = "A hakanssn project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, devshell }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };
      in {
        packages = flake-utils.lib.flattenTree rec {
          project = pkgs.hello;
          default = project;
        };
        devShells = rec {
          project-shell = pkgs.devshell.mkShell {
            name = "project-shell";
            packages = [ ];
            commands = [{
              package = "nixfmt";
              category = "formatter";
            }];
          };
          default = project-shell;
        };
      });
}
