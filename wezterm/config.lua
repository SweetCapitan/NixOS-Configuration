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
config.enable_wayland = false

local function get_current_working_dir(tab)
    local current_dir_url = tab.active_pane.current_working_dir
    -- Extract the filesystem path from the URL object
    local current_dir = current_dir_url.file_path
    local HOME_DIR = os.getenv("HOME")

    -- Handle home directory specially
    if current_dir == HOME_DIR then
        return "."
    else
        -- Extract just the directory name using pattern matching
        return current_dir:match("([^/]+)$") or current_dir
    end
end

wezterm.on(
    "format-tab-title",
    function(tab, tabs, panes, config, hover, max_width)
        local dir = get_current_working_dir(tab)
        local title = string.format(" %s  %s  ", "❯", dir or "unknown")

        return {
            {Text = title}
        }
    end
)

return config
