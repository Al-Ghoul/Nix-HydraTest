{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { nixpkgs, devenv, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells."${system}".default = devenv.lib.mkShell {
        inherit inputs pkgs;

        modules = [
          ({ ... }: {
            languages = {
              # nix.enable = true;
              c.enable = true;
              cplusplus.enable = true;
            };

            env = { MYSECRET = "nothing special"; };

            pre-commit.hooks = {
              deadnix.enable = true;
              nil.enable = true;
              nixfmt.enable = true;
              clang-format.enable = true;
              clang-tidy.enable = true;
              commitizen.enable = true;
              markdownlint.enable = true;
            };

            enterShell = ''
              echo "This is an entry point";
            '';
          })
        ];

      };
    };
}
