{
  description = "hm: tiny Home Manager helper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    forAll = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
      (system: f system (import nixpkgs { inherit system; }));
  in {
    packages = forAll (system: pkgs:
      let hmPkg = home-manager.packages.${system}.home-manager;
      in {
        default = pkgs.writeShellApplication {
          name = "hm";
          runtimeInputs = [ hmPkg ];
          text = builtins.readFile ./src/hm.sh;
        };
      }
    );

    apps = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: {
      default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/hm";
      };
    });

    # optional formatter for `nix fmt`
    formatter = forAll (system: pkgs: pkgs.nixfmt-rfc-style);
  };
}
