{ pkgs, lib, ... }:
{
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  systemd.user.services.niri-flake-polkit.enable = false;
  programs.xwayland.enable = true;

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk # ← вернуть!
    ];
    config.niri = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screencast" = [ "gnome" ];
      "org.freedesktop.impl.portal.Appearance" = [ "gnome" ];
      "org.freedesktop.impl.portal.Settings" = [ "gnome" ];
    };
    xdgOpenUsePortal = true;
  };

  # в system.nix, после portal блока:
  systemd.user.services.xdg-desktop-portal-gtk = {
    serviceConfig = {
      Environment = "GDK_BACKEND=wayland";
      Restart = "on-failure";
      RestartSec = "3s";
    };
  };

  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-agent = {
    description = "GNOME Polkit authentication agent (for niri)";
    wantedBy = [ "niri.service" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # GDM отключён — используем greetd PAM для keyring
  security.pam.services.greetd.enableGnomeKeyring = true; # ← было gdm
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    polkit_gnome
    wl-clipboard
    xwayland
    libsecret
    brightnessctl
    playerctl
  ];
}
