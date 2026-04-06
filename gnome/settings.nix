{ pkgs, ... }:
{
  services.gnome.gnome-browser-connector.enable = true;
  # services.xserver = {
  #  enable = true;
  #  # videoDrivers = [ "nvidia" ];
  #  displayManager.gdm.enable = true;
  #  displayManager.gdm.wayland = false;
  #  desktopManager = {
  #    gnome.enable = true;
  #    xterm.enable = false;
  #  };
  #  excludePackages = [ pkgs.xterm ];
  # };
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = false;
}
