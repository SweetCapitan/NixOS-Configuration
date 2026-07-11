{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.home) homeDirectory;

  papirusIconThemeSrc = pkgs.fetchFromGitHub {
    owner = "PapirusDevelopmentTeam";
    repo = "papirus-icon-theme";
    rev = "a1fd8b31af06ecfc3a30cf5dcbbc63f570ed1ac8";
    hash = "sha256-fRNXY7yDEjLCgePhO9mpT+HGteoJS5Pdfi4FipAEAUA=";
  };
  papirusDynamicSrc = pkgs.runCommand "papirus-dynamic-theme-src" { } ''
    mkdir -p "$out"
    cp -r --no-preserve=mode,ownership "${papirusIconThemeSrc}"/. "$out"/
    chmod -R u+w "$out"

    mv "$out/Papirus" "$out/Papirus-Dynamic"
    rm -rf "$out/Papirus-Light" "$out/Papirus-Dark"     # <-- добавить эту строку

    substituteInPlace "$out/Papirus-Dynamic/index.theme" \
      --replace 'Name=Papirus' 'Name=Papirus-Dynamic'
  '';
  iconsDir = "${homeDirectory}/.local/share/icons/Papirus-Dynamic";
in
{
  home.packages = with pkgs; [
    matugen
    papirus-folders
    gtk3
  ];

  xdg = {
    configFile = {
      "matugen/templates/papirus_color.json".text = ''
        {
          "primary": "{{colors.primary.default.hex}}",
          "primary_container": "{{colors.primary_container.default.hex}}"
        }
      '';
      "matugen/config.toml".source = ./matugen-config.toml;
      "matugen/templates/neovim-colors.lua".source = ./neovim-colors.lua;
      "matugen/templates/neovim-lualine.lua".text = ''
        return require("lualine.themes._base46")("dms")
      '';
    };
  };

  home.activation = {
    nvimColorsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${config.home.homeDirectory}/.config/nvim/colors"
    '';
    matugenCacheStub = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "${homeDirectory}/.cache/matugen"
      run touch "${homeDirectory}/.cache/matugen/papirus_color.json"
    '';
    papirusDynamicTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      stampFile="${iconsDir}.src-path"
      newSrc="${papirusDynamicSrc}/Papirus-Dynamic"
      tmpDir="${iconsDir}.tmp"

      if [ ! -e "${iconsDir}" ] || [ "$(cat "$stampFile" 2>/dev/null || true)" != "$newSrc" ]; then
        run rm -rf "$tmpDir"
        run mkdir -p "$(dirname "${iconsDir}")"
        # IMPORTANT: do not use cp -rL here.
        # Papirus relies heavily on internal symlink structure.
        # Dereferencing links breaks papirus-folders/dynamic recoloring.
        run cp -r --no-preserve=mode,ownership "$newSrc" "$tmpDir"
        run chmod -R u+w "$tmpDir"
        run rm -rf "${iconsDir}"
        run mv "$tmpDir" "${iconsDir}"
        run bash -c "echo '$newSrc' > '$stampFile'"
        run echo "MATUGEN_PAPIRUS: Papirus-Dynamic theme (re)installed from $newSrc"
      fi
    '';
    papirusIconCache = lib.hm.dag.entryAfter [ "papirusDynamicTheme" ] ''
      run ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t "${iconsDir}" || true
    '';
  };
}
# force rebuild 1783720337
