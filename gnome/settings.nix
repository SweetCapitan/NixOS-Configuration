{ pkgs, ... }:
{
  services.gnome.gnome-browser-connector.enable = true;
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager = {
      gnome.enable = true;
      xterm.enable = false;
    };
    excludePackages = [ pkgs.xterm ];
  };
}
