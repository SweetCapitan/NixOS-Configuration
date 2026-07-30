{ pkgs, lib, ... }:

let
  virtualPinsSrc = pkgs.fetchFromGitHub {
    owner = "pedrolamas";
    repo = "klipper-virtual-pins";
    rev = "9bda36567a9e394866eecc3f257680a8ec6e595b";
    sha256 = "sha256-IB8e369djc1WrsLmdM33IG99jgs+sreCT/Xl9DZoSS8=";
  };

in
pkgs.klipper.overrideAttrs (old: {
  postInstall = (old.postInstall or "") + ''
    chmod u+w $out/lib/klipper/extras
    cp ${virtualPinsSrc}/virtual_pins.py $out/lib/klipper/extras/virtual_pins.py
    chmod u-w $out/lib/klipper/extras
  '';
})
