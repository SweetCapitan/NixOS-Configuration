{
  pkgs ? import <nixpkgs> { },
}:

let
  lib = pkgs.lib;
in
pkgs.stdenv.mkDerivation rec {
  pname = "open-pencil";
  version = "0.4.0"; # Можно обновить до 0.5.0

  src = pkgs.fetchurl {
    url = "https://github.com/open-pencil/open-pencil/releases/download/v${version}/OpenPencil_${version}_amd64.deb";
    sha256 = "ThCXTCqsyAcLMv0G6Ysufxl+l44jrUorj6Vg5GwOTu4=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = with pkgs; [
    webkitgtk_4_1
    gtk3
    libsoup_3
    libayatana-appindicator
    openssl
    librsvg
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out
    cp -r usr/* $out/
    # Исправляем путь к бинарнику в .desktop файле
    substituteInPlace $out/share/applications/OpenPencil.desktop \
      --replace "/usr/bin/open-pencil" "$out/bin/open-pencil"
  '';
}
