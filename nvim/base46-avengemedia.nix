{ pkgs, lib }:

pkgs.vimUtils.buildVimPlugin {
  pname = "base46-avengemedia";
  version = "2026-07-11";

  src = pkgs.fetchFromGitHub {
    owner = "AvengeMedia";
    repo = "base46";
    rev = "cb8a1257bbc2640f6e7415a01219b34d3efd1494";
    hash = "sha256-6kK8q2dmmW3RO9FQmlcYN6Yyhl6fXE5ey1l8PWRVCfc=";
  };
  doCheck = false;
}
