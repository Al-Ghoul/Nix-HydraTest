{ nixpkgs, pulls }:
let
  pkgs = import nixpkgs { system = "x86_64-linux"; };

  prs = builtins.fromJSON (builtins.readFile pulls);
  prJobsets = builtins.mapAttrs (num: info: {
    enabled = 1;
    hidden = false;
    description = "PR ${num}:  ${info.title}";
    checkinterval = 60;
    schedulingshares = 20;
    enableemail = false;
    emailoverride = "";
    keepnr = 1;
    type = 1;
    flake = "github:Al-Ghoul/Nix-HydraTest/pull/${num}/head";
  }) prs;

  mkFlakeJobset = branch: {
    description = "Build ${branch}";
    checkinterval = 60;
    enabled = 1;
    schedulingshares = 100;
    enableemail = false;
    emailoverride = "";
    keepnr = 1;
    hidden = false;
    type = 1;
    flake = "github:Al-Ghoul/Nix-HydraTest/${branch}";
  };

  allJobsets = prJobsets // { "main" = mkFlakeJobset "main"; };

  log = {
    pulls = prs;
    jobsets = allJobsets;
  };
in {
  jobsets = pkgs.runCommand "spec-jobsets.json" { } ''
    cat >$out <<EOF
    ${builtins.toJSON allJobsets}
    EOF
    cat >tmp <<EOF
    ${builtins.toJSON log}
    EOF
    ${pkgs.jq}/bin/jq . tmp
  '';
}

