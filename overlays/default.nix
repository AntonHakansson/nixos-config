{ inputs, ... }: {
  additions = final: prev: import ../pkgs { pkgs = final; };
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable { system = final.system; };
  };
}
