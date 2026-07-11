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
      base03 = "{{colors.outline.default.hex}}",         -- было outline_variant → пунктуация была почти невидимой

      base04 = "{{colors.on_surface_variant.default.hex}}",
      base05 = "{{colors.on_surface.default.hex}}",

      base08 = "{{colors.error.default.hex}}",
      base09 = "{{colors.secondary.default.hex}}",
      base0A = "{{colors.tertiary.default.hex}}",
      base0B = "{{colors.primary.default.hex}}",
      base0C = "{{colors.tertiary.default.hex}}",          -- было tertiary_container
      base0D = "{{colors.primary.default.hex}}",           -- было primary_container
      base0E = "{{colors.secondary.default.hex}}",         -- было secondary_container → keywords были почти белыми
      base0F = "{{colors.inverse_primary.default.hex}}",
    }
  )
  base46.theme_tables[theme_name] = harmonized
end


base46.load(theme_name)

vim.g.colors_name = theme_name
