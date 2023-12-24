{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.callPackage
          ({ lib, buildGoModule, pkg-config, libappindicator-gtk3, libayatana-appindicator }:
            buildGoModule {
              pname = "syncthing-tray";
              version = "0.7";
              src = ./.;
              vendorHash = "sha256-kCDRQ+jO2lK72fPbsLZS848O99Nv3NY8xHM+sp8DQIM=";
              nativeBuildInputs = [ pkg-config ];
              buildInputs = [ libappindicator-gtk3 libayatana-appindicator ];
              meta = with lib; {
                description = "Simple application tray for syncthing";
                homepage = "https://github.com/stelcodes/syncthing-tray";
                license = licenses.mit;
              };
            })
          { };


        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.go
            pkgs.gopls
            pkgs.golint
            pkgs.graphviz # for `go tool pprof`
          ];
          shellHook = ''
            echo 'Entering Nix dev shell...'
          '';
        };
      });
}
