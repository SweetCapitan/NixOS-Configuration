{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  dmsHomeModule = import ./dms/homeModules.nix {
    inherit
      config
      pkgs
      lib
      inputs
      ;
  };
in

{
  imports = [
    ./nvim/neovim.nix
    dmsHomeModule
  ];

  home.username = "dancho";
  home.homeDirectory = "/home/dancho";
  home.packages =
    with pkgs;
    [
      htop
      kubectl # TODO: home kubectl config
      obsidian
    ]
    ++ (with jetbrains; [ idea ]);
  programs.bash = {
    enable = true;
    initExtra = ''
            # Включаем Starship только в графической сессии
      if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        eval "$(${pkgs.starship}/bin/starship init bash)"
      fi
    '';
  };
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    systemd.enable = true;
    settings = {
      theme = "dark:dankcolors,light:dankcolors";
      shell-integration-features = "ssh-terminfo,ssh-env";
      window-decoration = "none";
      window-theme = "ghostty";
      background-opacity = 0.4;
      background-blur = 10;
      #theme = "dark:JetBrains Darcula,light:Material";
    };
  };
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "SweetCapitan";
        email = "danil.duhanin@yandex.ru";
      };
    };
  };

  programs.starship = import ./home/starship.nix;
  dconf.settings = with lib.hm.gvariant; {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
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
