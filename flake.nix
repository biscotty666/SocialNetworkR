{
  description = "An R flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
        myPackages = {
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
          myGoldfish = pkgs.rPackages.buildRPackage {
            name = "goldfish";
            src = pkgs.fetchFromGitHub {
              owner = "stocnet";
              repo = "goldfish";
              rev = "a53fa5390fa0cb879eda640441c53c0b06ba7391";
              sha256 = "gkHMDhRqWCL4slaGjjDsek050N6eFyG0zllWN/SWx7A=";
            };
            propagatedBuildInputs = with pkgs.rPackages; [
              Rcpp
              changepoint
              generics
              ggplot2
              rlang
              tibble
              cli
              lifecycle
              RcppArmadillo
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
              igraph
              Rcpp
              Matrix
            ];
          };
          myg6R = pkgs.rPackages.buildRPackage {
            name = "g6R";
            src = pkgs.fetchFromGitHub {
              owner = "cynkra";
              repo = "g6R";
              rev = "901f6aa04206cc19b388c788c087ede3ddc3da6f";
              sha256 = "d0o0sj6sqnCnu2xfg7/hFzhqXD/pLXQRFIpycCEf60k=";
            };
            propagatedBuildInputs = with pkgs.rPackages; [
              igraph
              Rcpp
              htmlwidgets
              shiny
            ];
          };
          myNetropy = pkgs.rPackages.buildRPackage {
            name = "netropy";
            src = pkgs.fetchFromGitHub {
              owner = "termehs";
              repo = "netropy";
              rev = "a35d1272f6ea6b36437c3c23abbe24e02dbf6443";
              sha256 = "//fn5H2fZqJuolB2SzwzcVAXEBigGCPHVRdpDIN6n44=";
            };
            propagatedBuildInputs = with pkgs.rPackages; [
              igraph
              Rcpp
              ggraph
              ggplot2
            ];
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = builtins.attrValues {
            inherit (myPackages)
              networkdata
              myBackbone
              myg6R
              myGoldfish
              myNetropy
              ;
            inherit (pkgs)
              R
              quarto
              chromium
              pandoc
              rstudio
              ;
            inherit (pkgs.texlive.combined) scheme-medium;
            inherit (pkgs.rPackages)
              blockmodeling
              egor
              igraph
              # g6R
              GA
              ggforce
              ggraph
              migraph
              # goldfish
              graphlayouts
              htmlTable
              htmltools
              htmlwidgets
              intergraph
              knitr
              manynet
              MASS
              maps
              netrankr
              # netropy
              networkD3
              netUtils
              oaqc
              osmextract
              patchwork
              Rglpk
              RSiena
              r5r
              rJavaEnv
              relevent
              sf
              shadowtext
              signnet
              statnet
              styler
              threejs
              tidygraph
              tidyverse
              tnet
              visNetwork
              webshot2
              zeallot
              ;
          };
          shellHook = "";
        };
      }
    );
}
