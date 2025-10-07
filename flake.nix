{
  description = "hm: tiny helper CLI (pure shell)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAll = f: nixpkgs.lib.genAttrs systems (system: f system (import nixpkgs { inherit system; }));
  in {
    packages = forAll (system: pkgs: {
      default = pkgs.stdenv.mkDerivation {
        pname = "hm";
        version = "0.1.0";
        src = ./.;

        # We’ll use these helpers to install the script and completions.
        nativeBuildInputs = [ pkgs.installShellFiles ];

        installPhase = ''
          install -Dm0755 src/hm.sh "$out/bin/hm"
          installShellCompletion \
            --bash completions/hm.bash \
            --zsh  completions/_hm \
            --fish completions/hm.fish
        '';
      };
    });

    apps = nixpkgs.lib.genAttrs systems (system: {
      default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/hm";
      };
    });

    formatter = forAll (system: pkgs: pkgs.nixfmt-rfc-style);
  };
}
