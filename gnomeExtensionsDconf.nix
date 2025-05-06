{ lib, ... }:

{
  dconf.settings = with lib.gvariant; {
    "org/gnome/shell/extensions/lennart-k/rounded_corners" = {
      "corner-radius" = mkInt32 12;
    };

    "org/gnome/shell/extensions/sp-tray" = {
      "display-format" = mkString "{artist} | {track} ";
      "paused"         = mkString "⏸️";
      "stopped"        = mkString "⏹️";
    };
  };
}
