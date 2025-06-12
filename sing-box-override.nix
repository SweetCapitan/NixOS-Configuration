{config, pkgs, ...}: 

{
  nixpkgs.overlays = [
    (self: super: {
      sing-box = let
        pinnedPkgs = import (super.fetchFromGitHub {
          owner = "nixos";
          repo = "nixpkgs";
          rev = "0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb";
          hash = "sha256-42okGEXT2cPw3xfSxpb+L/O1YdIM/luq4poIuqEW/Fk=";
        }) {system = super.system;};
      in pinnedPkgs.sing-box;
    })
];
}
