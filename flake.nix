{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, devenv, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells."${system}".default = devenv.lib.mkShell {
        inherit inputs pkgs;

        modules = [
          ({ pkgs, ... }: {

            packages = with pkgs; [ clang_17 cmake gnumake cz-cli yarn ];

            pre-commit.hooks = {
              deadnix.enable = true;
              nil.enable = true;
              nixfmt.enable = true;

              clang-format.enable = true;
              clang-tidy.enable = true;

              commitizen.enable = true;
              markdownlint.enable = true;
            };

          })
        ];

      };

      hydraJobs = let stdenv = pkgs.llvmPackages_17.stdenv;
      in rec {
        build = stdenv.mkDerivation (finalAttrs: {
          version = "1.0.0";
          pname = "Hello";
          src = self;

          nativeBuildInputs = [ pkgs.cmake ];

          dontPatch = true;

          configurePhase = ''
            runHook preConfigure
            cmake -H. -B./build 
            runHook postConfigure
          '';

          buildPhase = ''
            runHook preBuild
            cd build
            make
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp Hello $out/bin
            runHook postInstall
          '';

          doCheck = false;

          passthru.tests.run = pkgs.runCommand "hello-test" {
            nativeBuildInputs = [ finalAttrs.finalPackage ];
          } ''
            diff -U3 --color=auto <(Hello) <(echo 'Hello G')
            touch $out
          '';

        });

        tests = build.tests;

        required = pkgs.releaseTools.aggregate {
          name = "final-builds";
          constituents = [ tests build ];
          meta = {
            description = "Still don't know what to put here";
            homepage = "https://github.com/Al-Ghoul/Nix-HydraTest";
            maintainers = [{ email = "Abdo.AlGhouul@gmail.com"; }];
          };
        };
      };

    };
}
