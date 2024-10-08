{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "dancho";
  home.homeDirectory = "/home/dancho";
  home.packages = with pkgs; [
    htop
    kubectl #TODO: home kubectl config
  ];
  programs.git = {
    enable = true;
    userName = "SweetCapitan";
    userEmail = "danil.duhanin@yandex.ru";
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
