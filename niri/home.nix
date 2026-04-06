# niri/home.nix
# Home-Manager configuration for the niri session with DankMaterialShell.
# Provides: niri config, DMS shell, swww wallpaper.

{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{

  systemd.user.services.xdg-desktop-portal-gtk = {
    Service.Environment = [ "GDK_BACKEND=wayland" ];
  };

  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Note: enableKeybinds requires niri-flake module, using nixpkgs niri instead
    # niri keybinds must be configured manually in niri config
  };

  xdg.configFile."niri/keyboard.kdl".text = ''
    input {
        keyboard {
          xkb {
            layout "us,ru"
            options "grp:alt_shift_toggle"
          }
          track-layout "window"
        }
      }  
  '';

  home.packages = with pkgs; [
    swww
    wlogout
    fuzzel
    gnome-control-center
    networkmanagerapplet
    pavucontrol
    cliphist
    wl-clipboard
    libnotify
    swaylock-effects
    grim
    slurp
  ];

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "DMS";
    QT_QPA_PLATFORM = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  xdg.desktopEntries.spotify = {
    name = "Spotify";
    exec = "spotify --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
    icon = "spotify";
  };

  home.pointerCursor = {
    name = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.waybar.enable = false;
  services.mako.enable = false;

  xdg.configFile."swaylock/config".text = ''
    image=~/.config/niri/wallpaper.jpg
    scaling=fill
    effect-blur=10x10
    effect-vignette=0.5:0.5
    color=282828
    ring-color=d65d0e
    key-hl-color=d79921
    text-color=ebdbb2
    font=JetBrainsMono Nerd Font Mono
    indicator-radius=100
    indicator-thickness=10
    show-failed-attempts
  '';

  xdg.configFile."wlogout/layout".text = ''
    {
      "label" : "lock",
      "action" : "swaylock",
      "text" : "Lock",
      "keybind" : "l"
    }
    {
      "label" : "logout",
      "action" : "loginctl terminate-user $USER",
      "text" : "Logout",
      "keybind" : "e"
    }
    {
      "label" : "suspend",
      "action" : "systemctl suspend",
      "text" : "Suspend",
      "keybind" : "u"
    }
    {
      "label" : "reboot",
      "action" : "systemctl reboot",
      "text" : "Reboot",
      "keybind" : "r"
    }
    {
      "label" : "shutdown",
      "action" : "systemctl poweroff",
      "text" : "Shutdown",
      "keybind" : "s"
    }
  '';

  xdg.configFile."wlogout/style.css".text = ''
    * { background: transparent; }
    window {
      background-color: rgba(40,40,40,0.85);
    }
    button {
      background-color: #3c3836;
      color:            #ebdbb2;
      font-family:      "JetBrainsMono Nerd Font Mono";
      font-size:        14px;
      border-radius:    12px;
      margin:           10px;
      border:           2px solid #504945;
    }
    button:hover {
      background-color: #d65d0e;
      color:            #282828;
      border-color:     #d65d0e;
    }
  '';
}
