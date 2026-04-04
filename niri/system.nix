# niri/system.nix
# System-level NixOS configuration for the niri Wayland compositor.
# Keeps GNOME fully intact — niri is just an additional session in GDM.
#
# Add to flake.nix modules list:
#   ./niri/system.nix

{ pkgs, ... }:

{
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  systemd.user.services.niri-flake-polkit.enable = false;

  programs.xwayland.enable = true;

  # ── XDG portals ─────────────────────────────────────────────────────────────
  # Re-use GNOME's portal implementations for file picker, screenshots, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.niri = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screencast" = [ "gnome" ];
    };
  };

  # ── Polkit agent (GNOME's agent doesn't start outside GNOME shell) ───────────
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

  # ── Keyring (same PAM unlock as GNOME uses via GDM) ──────────────────────────
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # ── Extra system packages needed under niri ───────────────────────────────────
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    polkit_gnome # auth dialogs
    wl-clipboard # wl-copy / wl-paste (clipboard)
    xwayland # X11 app compat
    libsecret # secret-tool + keyring access for apps
    brightnessctl # screen brightness control (keyboard keys)
    playerctl # media key support (play/pause/next)
  ];
}
