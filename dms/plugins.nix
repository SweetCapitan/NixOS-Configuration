{ pkgs, lib }:
{
  dockerManager = {
    enable = lib.mkForce true;
    src = lib.mkForce (
      pkgs.fetchFromGitHub {
        owner = "LuckShiba";
        repo = "DmsDockerManager";
        rev = "v1.2.0";
        sha256 = "sha256-VoJCaygWnKpv0s0pqTOmzZnPM922qPDMHk4EPcgVnaU=";
      }
    );
    settings = {
      enabled = true;
      dockerBinary = "podman";
    };
  };
  activateLinux = {
    enable = lib.mkForce true;
    src = lib.mkForce (
      pkgs.fetchFromGitHub {
        owner = "hthienloc";
        repo = "dms-activate-linux";
        rev = "34f359aedcac9d27ff5df51d43cc41031ea00f80";
        sha256 = "sha256-iWfw7WF6EiLUnsQgsyJWGuacU09eyZZRdMBbRp7E/DA=";
      }
    );
    settings = {
      enabled = true;
    };
  };
  dankKDEConnect = {
    enable = lib.mkForce true;
    src = lib.mkForce (
      pkgs.runCommand "DankKDEConnect-source" { } ''
        mkdir -p $out
        cp -rT ${
          pkgs.fetchFromGitHub {
            owner = "AvengeMedia";
            repo = "dms-plugins";
            rev = "master";
            hash = "sha256-QkQPqP7Wmo5DLRyKNSY5NuOau4LSaSfz3DYdHDLxluA=";
          }
        }/DankKDEConnect $out/
      ''
    );
    settings = {
      enabled = true;
      selectedDeviceId = "4bc00011_17ea_4b2d_aa95_6a03c0b54803";
    };
  };
}
