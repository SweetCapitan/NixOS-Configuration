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
      "matugen/templates/neovim-colors.lua".text = ''
        local base46 = require("base46")

        local theme_name = "dms"

        local mode = vim.system(
          { "dms", "ipc", "call", "theme", "getMode" },
          { text = true }
        ):wait().stdout

        if mode and mode:match("light") then
          vim.o.background = "light"
        else
          vim.o.background = "dark"
        end


        if not base46.theme_tables[theme_name] then
          local builtin_name

          if vim.o.background == "light" then
            builtin_name = "github_light"
          else
            builtin_name = "github_dark"
          end


          local builtin = vim.deepcopy(
            assert(base46.get_builtin_theme(builtin_name))
          )


          local harmonized = base46.theme_harmonize(
            builtin,
            "{{colors.source_color.default.hex}}",
            0.5
          )


          harmonized = base46.theme_set_bg(
            harmonized,
            "{{colors.background.default.hex}}"
          )


          -- Material 3 overrides
          harmonized.base_30 = vim.tbl_extend(
            "force",
            harmonized.base_30,
            {
              black = "{{colors.surface.default.hex}}",
              darker_black = "{{colors.surface_dim.default.hex}}",

              one_bg = "{{colors.surface_container_low.default.hex}}",
              one_bg2 = "{{colors.surface_container.default.hex}}",
              one_bg3 = "{{colors.surface_container_high.default.hex}}",

              grey = "{{colors.outline.default.hex}}",
              grey_fg = "{{colors.on_surface_variant.default.hex}}",

              white = "{{colors.on_surface.default.hex}}",

              red = "{{colors.error.default.hex}}",
              green = "{{colors.primary.default.hex}}",
              blue = "{{colors.tertiary.default.hex}}",
              yellow = "{{colors.secondary.default.hex}}",

              nord_blue = "{{colors.primary_container.default.hex}}",

              statusline_bg = "{{colors.surface_container.default.hex}}",

              pmenu_bg = "{{colors.primary.default.hex}}",
              folder_bg = "{{colors.primary.default.hex}}",

              line = "{{colors.outline_variant.default.hex}}",
            }
          )


          harmonized.base_16 = vim.tbl_extend(
            "force",
            harmonized.base_16,
            {
              base00 = "{{colors.background.default.hex}}",
              base01 = "{{colors.surface_container_low.default.hex}}",
              base02 = "{{colors.surface_container.default.hex}}",
              base03 = "{{colors.outline.default.hex}}",              -- было outline_variant → пунктуация была почти невидимой

              base04 = "{{colors.on_surface_variant.default.hex}}",
              base05 = "{{colors.on_surface.default.hex}}",

              base08 = "{{colors.error.default.hex}}",
              base09 = "{{colors.secondary.default.hex}}",
              base0A = "{{colors.tertiary.default.hex}}",
              base0B = "{{colors.primary.default.hex}}",
              base0C = "{{colors.tertiary.default.hex}}",             -- было tertiary_container
              base0D = "{{colors.primary.default.hex}}",              -- было primary_container
              base0E = "{{colors.secondary.default.hex}}",            -- было secondary_container → keywords были почти белыми
              base0F = "{{colors.inverse_primary.default.hex}}",
            }
          )
          base46.theme_tables[theme_name] = harmonized
        end


        base46.load(theme_name)

        vim.g.colors_name = theme_name
      '';
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
