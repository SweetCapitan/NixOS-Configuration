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
      terminalApp = "ghostty";
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
      # enabled = true;
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
      # enabled = true;
      selectedDeviceId = "4bc00011_17ea_4b2d_aa95_6a03c0b54803";
    };
  };
  calculator = {
    enable = true;
    # src = pkgs.fetchFromGitHub {
    #   owner = "rochacbruno";
    #   repo = "DankCalculator";
    #   rev = "1db5865419a40a33171a475855a59e0b8bf7187f";
    #   hash = "sha256-j8C62+sevr6b+akzVSAqUVysIhb6Vbr8jnWcTXeOtE8=";
    # };
    settings = {
      # enabled = true;
    };
  };
  screenCaptureToolbar = {
    # src = pkgs.fetchFromGitHub {
    #   owner = "JDKamalakar";
    #   repo = "DMS-ScreenCapture_Toolbar";
    #   rev = "5a307c53362f1c347d5dad697bb33c1e6869f910";
    #   hash = "sha256-6vmoL1y0Joxqa8bF8zIUcpaBW8Jv0T+sD4M050OoW/Q=";
    # };
    enable = true;
    settings = {
      enabled = true;
      showAdvancedSettings = true;
    };
  };
}
