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
  home.packages =
    with pkgs;
    [
      htop
      kubectl # TODO: home kubectl config
      gnome.gnome-tweaks
      obsidian
    ]
    ++ (with jetbrains; [ idea-ultimate ]);
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    extraConfig = ''
      ${builtins.readFile ./wezterm/config.lua}
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
