{
  description = "A basic flake with a shell";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/25.11";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        #pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        networkdata = pkgs.rPackages.buildRPackage {
          name = "networkdata";
          src = pkgs.fetchFromGitHub {
            owner = "schochastics";
            repo = "networkdata";
            rev = "521594049f725c3962c11496d5b0f48386ee84b2";
            sha256 = "nSl/eNUMdNFxowNaHJ1g1YfQ4gx8oKEfiFki0wdwQ7k=";
          };
          propagatedBuildInputs = with pkgs.rPackages; [
            igraph
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.bashInteractive ];
          buildInputs = with pkgs; [
            R
            quarto
            chromium
            pandoc
            texlive.combined.scheme-full
            rstudio
            (with rPackages; [
              backbone
              blockmodeling
              egor
              igraph
              g6R
              ggforce
              ggraph
              graphlayouts
              intergraph
              knitr
              MASS
              netrankr
              netropy
              networkD3
              networkdata
              netUtils
              patchwork
              RSiena
              relevent
              signnet
              statnet
              threejs
              tidygraph
              tidyverse
              tnet
              visNetwork
            ])
          ];
          shellHook = "";
        };
      }
    );
}
