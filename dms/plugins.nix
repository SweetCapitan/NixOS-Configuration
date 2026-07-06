{ pkgs }:
{
  DockerManager = {
    src = pkgs.fetchFromGitHub {
      owner = "LuckShiba";
      repo = "DmsDockerManager";
      rev = "v1.2.0";
      sha256 = "sha256-VoJCaygWnKpv0s0pqTOmzZnPM922qPDMHk4EPcgVnaU=";
    };
  };
  ActivateLinux = {
    src = pkgs.fetchFromGitHub {
      owner = "hthienloc";
      repo = "dms-activate-linux";
      rev = "34f359aedcac9d27ff5df51d43cc41031ea00f80";
      sha256 = "sha256-iWfw7WF6EiLUnsQgsyJWGuacU09eyZZRdMBbRp7E/DA=";
    };
  };
  DankKDEConnect = {
    src = pkgs.runCommand "DankKDEConnect-source" { } ''
      mkdir -p $out
      cp -rT ${
        pkgs.fetchFromGitHub {
          owner = "AvengeMedia";
          repo = "dms-plugins";
          rev = "master";
          hash = "sha256-QkQPqP7Wmo5DLRyKNSY5NuOau4LSaSfz3DYdHDLxluA=";
        }
      }/DankKDEConnect $out/
    '';
  };
}
