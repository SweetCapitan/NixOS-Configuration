{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.dms-plugin-registry.nixosModules.default ];
  programs.niri = {
    enable = true;
  };
  programs.dms-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableVPN = true; # VPN management widget
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
    enableClipboardPaste = true;
    plugins = {
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
          # Копируем содержимое конкретной подпапки из скачанного репозитория в корень
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

      # PhoneConnect = {
      #   src = pkgs.fetchFromGitHub {
      #     owner = "AvengeMedia";
      #     repo = "dms-plugins";
      #     rev = "f4583449f12920e0a2f16808b00a860c27f0173d";
      #     sparseCheckout = [
      #       "dms-plugins/DankKDEConnect"
      #     ];
      #     rootDir = "dms-plugins/DankKDEConnect";
      #     hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      #   };
      # };
    };
  };
  services.displayManager.dms-greeter = {
    enable = true;
    compositor = {
      name = "niri";
    };
  };
}
