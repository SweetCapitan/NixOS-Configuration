{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:

let
  dms-bin = "${lib.getBin inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin";
  qs-bin = "${lib.getBin pkgs.quickshell}/bin";
in
{
  options.shell.dms = lib.mkEnableOption "DankMaterialShell";

  config = lib.mkIf config.shell.dms {
    imports = [ inputs.dms.homeModules.dank-material-shell ];

    programs.dank-material-shell = {
      enable = true;
      systemd.enable = true;
    };

    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "DMS";
      PATH = "${dms-bin}:${qs-bin}:$PATH";
    };
  };
}
