{
  description = "hm: tiny Home Manager helper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
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

    # Home Manager module so others can do: programs.hm.enable = true;
    homeManagerModules.hm = { lib, config, pkgs, ... }:
      let
        cfg = config.programs.hm;
      in {
        options.programs.hm = {
          enable = lib.mkEnableOption "the hm helper CLI";
          package = lib.mkOption {
            type = lib.types.package;
            default = self.packages.${pkgs.system}.default;
            description = "Which hm package to install.";
          };
          createAlias = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Add 'hm' alias to shells.";
          };
        };

        config = lib.mkIf cfg.enable {
          home.packages = [ cfg.package ];
          programs.bash.shellAliases = lib.mkIf cfg.createAlias { hm = "hm"; };
          programs.zsh.shellAliases  = lib.mkIf cfg.createAlias { hm = "hm"; };
          # Add other shells here if you like (fish, etc.).
        };
      };

    # optional formatter for `nix fmt`
    formatter = forAll (system: pkgs: pkgs.nixfmt-rfc-style);
  };
}
