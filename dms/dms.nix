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
    plugins = import ./plugins.nix { inherit pkgs; };
  };
  services.displayManager.dms-greeter = {
    enable = true;
    compositor = {
      name = "niri";
    };
    configHome = "/home/dancho";
  };
}
