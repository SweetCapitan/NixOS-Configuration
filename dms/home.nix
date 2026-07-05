{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
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

  # home.sessionVariables = {
  #   XDG_CURRENT_DESKTOP = "DMS";
  #   QT_QPA_PLATFORM = "wayland";
  #   XDG_SESSION_TYPE = "wayland";
  # };
  #
  # home.pointerCursor = {
  #   name = "Adwaita";
  #   size = 24;
  #   package = pkgs.adwaita-icon-theme;
  #   gtk.enable = true;
  #   x11.enable = true;
  # };
}
