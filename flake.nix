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
        myBackbone = pkgs.rPackages.buildRPackage {
          name = "backbone";
          src = pkgs.fetchFromGitHub {
            owner = "zpneal";
            repo = "backbone";
            rev = "9a584b4e56d633eb5ca04a15e7849ec5ff4daa2d";
            sha256 = "VPovHY5TXt8wB0QEHb0GzM0jVk8yVSy7Vk5EEDkhnRU=";
          };
          propagatedBuildInputs = with pkgs.rPackages; [
            igraph Rcpp Matrix 
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
              # backbone
              myBackbone
              blockmodeling
              egor
              igraph
              g6R
              GA
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
              styler
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
