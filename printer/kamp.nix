{ pkgs, lib, ... }:

let
  kampSrc = pkgs.fetchFromGitHub {
    owner = "kyleisah";
    repo = "Klipper-Adaptive-Meshing-Purging";
    rev = "b0dad8ec9ee31cb644b94e39d4b8a8fb9d6c9ba0";
    sha256 = "sha256-05l1rXmjiI+wOj2vJQdMf/cwVUOyq5d21LZesSowuvc=";
  };
in
{
  systemd.tmpfiles.rules = [
    "L+ /var/lib/moonraker/config/KAMP - - - - ${kampSrc}/Configuration"

    "C /var/lib/moonraker/config/KAMP_Settings.cfg - - - - ${kampSrc}/Configuration/KAMP_Settings.cfg"
  ];
}
