{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.dms-plugin-registry.nixosModules.default
    inputs.dms.homeModules.dank-material-shell
  ];
  programs.dank-material-shell = {
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
    plugins = import ./plugins.nix { inherit pkgs; };
    quickshell.package = pkgs.quickshell;
  };
  xdg.configFile."DankMaterialShell/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Configurations/dms/settings.json";
  xdg.configFile."niri/keyboard.kdl".text = ''
    input {
        keyboard {
          xkb {
            layout "us,ru"
            options "grp:alt_shift_toggle"
          }
          track-layout "window"
        }
      }  
  '';
  xdg.configFile."niri/blur.kdl".text = ''
      window-rule {
      opacity 0.95
      background-effect {
        blur true
      }
    }
  '';

}
