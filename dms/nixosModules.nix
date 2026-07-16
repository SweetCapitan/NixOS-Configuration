{
  pkgs,
  ...
}:
{
  programs.niri = {
    enable = true;
  };
  services.displayManager.dms-greeter = {
    enable = true;
    compositor = {
      name = "niri";
    };
    configHome = "/home/dancho";
  };
  security.polkit.enable = true;
  # fix gparted
  environment.systemPackages = with pkgs; [
    # qt6Packages.qt6ct
    kdePackages.qt6ct
    libsForQt5.qt5ct
  ];
}
