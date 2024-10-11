{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./gnomeExtensions.nix ];
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "dancho";
  home.homeDirectory = "/home/dancho";
  home.packages = with pkgs; [
    htop
    kubectl # TODO: home kubectl config
    gnome.gnome-tweaks
  ];
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    extraConfig = ''
	local wezterm = require 'wezterm'

	local config = wezterm.config_builder()

	function scheme_for_appearance(appearance)
	if appearance:find 'Dark' then
		return 'GruvboxDarkHard'
	else
		return 'GruvboxLight'
			end
			end

			wezterm.on('window-config-reloaded', function(window, pane)
					local overrides = window:get_config_overrides() or {}
					local appearance = window:get_appearance()
					local scheme = scheme_for_appearance(appearance)
					if overrides.color_scheme ~= scheme then
					overrides.color_scheme = scheme
					window:set_config_overrides(overrides)
					end
					end)

			config.window_decorations = "TITLE | RESIZE"

			config.font =
			wezterm.font('JetBrains Mono', { weight = 'Medium', italic = false })
			config.font_size = 10.0

			config.initial_cols = 100
			config.initial_rows = 20
			config.window_close_confirmation = 'NeverPrompt'

			local function get_current_working_dir(tab)
			local current_dir = tab.active_pane.current_working_dir
			local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

			return current_dir == HOME_DIR and "." or string.gsub(current_dir, "(.*[/\\])(.*)", "%2")
			end


			wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)


					local title = string.format(" %s  %s ~ %s  ", "❯", get_current_working_dir(tab))


					return {
					{ Text = title },
					}
					end)

			return config
    '';
  };
  programs.git = {
    enable = true;
    userName = "SweetCapitan";
    userEmail = "danil.duhanin@yandex.ru";
  };
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [
        "<Alt>Shift_L"
        "<Shift>Alt_L"
        "<Alt>Shift_R"
        "<Shift>Alt_R"
        "<Super>space"
      ];
    };
  };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
