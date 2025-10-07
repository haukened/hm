{
  description = "hm: tiny helper CLI (pure shell)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system (import nixpkgs { inherit system; }));
  in {
    packages = forAllSystems (system: pkgs: {
      # Builds a real package from your shell script at ./src/hm.sh
      default = pkgs.writeShellApplication {
        name = "hm";
        text = builtins.readFile ./src/hm.sh;
      };
    });

    # `nix run .` or `nix run github:haukened/hm`
    apps = nixpkgs.lib.genAttrs systems (system: {
      default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/hm";
      };
    });

    # Optional: `nix fmt`
    formatter = forAllSystems (system: pkgs: pkgs.nixfmt-rfc-style);
  };
}
