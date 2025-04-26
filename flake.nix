{
  description = "Flake for MS-365-Electron";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs    = import nixpkgs { inherit system; };
        pkgJson = builtins.fromJSON (builtins.readFile ./package.json);
        version = pkgJson.version;
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.nodejs pkgs.yarn pkgs.electron ];
          shellHook = ''
            echo "↳ installing deps…"
            yarn install --immutable   # uses your yarn.lock
            echo "run ‘yarn start’ to launch the app"
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "ms-365-electron";
          inherit version;

          src = ./.;
          dontUnpack = true;      # we’re using the repo root directly

          nativeBuildInputs = [ pkgs.yarn ];
          buildInputs       = [ pkgs.nodejs ];

          phases = [ "installDeps" "buildBundle" "installPhase" ];

          installDeps = ''
            yarn install --immutable      # install all deps :contentReference[oaicite:0]{index=0}
          '';

          buildBundle = ''
            yarn dist                     # runs electron-builder :contentReference[oaicite:1]{index=1}
          '';

          installPhase = ''
            mkdir -p $out
            cp -r release/* $out/         # copy AppImage/.deb/.rpm/etc into $out
          '';
        };
      }
    );
}
