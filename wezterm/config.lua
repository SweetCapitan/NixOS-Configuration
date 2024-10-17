local wezterm = require "wezterm"

local config = wezterm.config_builder()

function scheme_for_appearance(appearance)
    if appearance:find "Dark" then
        return "GruvboxDarkHard"
    else
        return "GruvboxLight"
    end
end

wezterm.on(
    "window-config-reloaded",
    function(window, pane)
        local overrides = window:get_config_overrides() or {}
        local appearance = window:get_appearance()
        local scheme = scheme_for_appearance(appearance)
        if overrides.color_scheme ~= scheme then
            overrides.color_scheme = scheme
            window:set_config_overrides(overrides)
        end
    end
)

config.window_decorations = "TITLE | RESIZE"

config.font = wezterm.font("JetBrains Mono", {weight = "Medium", italic = false})
config.font_size = 10.0

config.initial_cols = 120
config.initial_rows = 25
config.window_close_confirmation = "NeverPrompt"

local function get_current_working_dir(tab)
    local current_dir = tab.active_pane.current_working_dir
    local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

    return current_dir == HOME_DIR and "." or string.gsub(current_dir, "(.*[/\\])(.*)", "%2")
end

wezterm.on(
    "format-tab-title",
    function(tab, tabs, panes, config, hover, max_width)
        local title = string.format(" %s  %s ~ %s  ", "❯", get_current_working_dir(tab))

        return {
            {Text = title}
        }
    end
)

return config
