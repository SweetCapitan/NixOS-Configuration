# niri/home.nix
# Home-Manager configuration for the niri session.
# Provides: niri config, waybar panel, mako notifications, swww wallpaper.
# Import in home.nix:
#   imports = [ ./gnomeExtensions.nix ./gnomeExtensionsDconf.nix ./niri/home.nix ];

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ── Packages used by the niri session ────────────────────────────────────────
  home.packages = with pkgs; [
    waybar # panel (GNOME-bar replacement)
    mako # notification daemon (replaces GNOME's built-in)
    swww # wallpaper daemon
    wlogout # logout / lock screen menu
    fuzzel # app launcher (fast, Wayland-native)
    gnome-control-center # settings app still works under niri
    networkmanagerapplet # nm-applet for the tray
    pavucontrol # volume control
    cliphist # clipboard history (wl-clipboard based)
    wl-clipboard
    libnotify # notify-send helper
    swaylock-effects # lockscreen with blur (matches GNOME blur ext)
    grim # screenshot
    slurp # area selection for screenshots
    spotify
  ];

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

  # ── niri compositor config ────────────────────────────────────────────────────
  # Written to ~/.config/niri/config.kdl
  xdg.configFile."niri/config.kdl".text = ''
    // ── Input ────────────────────────────────────────────────────────────────
    input {
      keyboard {
        xkb {
          // Match your GNOME keyboard layout (en + ru, Alt+Shift to switch)
          layout "us,ru"
          options "grp:alt_shift_toggle"
        }
        repeat-delay 600
        repeat-rate  25
        track-layout "window"
      }
      mouse {
        accel-speed 0.0
      }
      touchpad {
        tap
        natural-scroll
        accel-speed 0.2
      }
      // Warp cursor to centre of focused window (like GNOME focus-follows-mouse)
      warp-mouse-to-focus
      focus-follows-mouse max-scroll-amount="0%"
    }

    // ── Output / display ──────────────────────────────────────────────────────
    // niri auto-detects outputs; add explicit config here if needed:
    // output "HDMI-A-1" {
    //   mode "1920x1080@60"
    //   scale 1.0
    // }

    output "Samsung Electric Company S22C300 HLPDB00705" {
      mode "1920x1080@60.000"
      scale 1.0
      position x=0 y=0
    }

    output "Acer Technologies V193HQ LEP0C0284008" {
      mode "1366x768@59.790"
      scale 1.0
      position x=1920 y=312
    }

    // ── Appearance ────────────────────────────────────────────────────────────
    layout {
      // Gap between windows (similar to GNOME's window spacing)
      gaps 12

      // Center-focussed column: keeps the active window centred like GNOME
      center-focused-column "never"

      preset-column-widths {
        proportion 0.333
        proportion 0.5
        proportion 0.667
        proportion 1.0
      }
      default-column-width { proportion 0.5; }

      focus-ring {
        // Gruvbox orange accent — matches your starship / gruvbox theme
        width 2
        active-color "#d65d0e"
        inactive-color "#3c3836"
      }

      border {
        off
      }

      shadow {
        on
        softness 30
        spread   5
        offset  x=0 y=5
        color "#00000055"
      }

    }


    // ── Animations ────────────────────────────────────────────────────────────
    animations {
      // Smooth, similar to GNOME's default animations
      slowdown 1.0
    }

    // ── Startup ───────────────────────────────────────────────────────────────
    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "swww-daemon"
    spawn-at-startup "nm-applet" "--indicator"
    spawn-at-startup "wl-paste" "--type" "text" "--watch" "cliphist" "store"

    // Restore GNOME wallpaper on start via swww
    // Edit the path to your actual wallpaper file:
    spawn-at-startup "sh" "-c" "sleep 1 && swww img ~/.config/niri/wallpaper.jpg --transition-type fade --transition-duration 1"

    // ── Prefer server-side decorations (like GNOME) ────────────────────────────
    prefer-no-csd

    // ── Screenshot directory (same as GNOME default) ──────────────────────────
    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    // ── Window rules ──────────────────────────────────────────────────────────
    window-rule {
      match app-id="gnome-control-center"
      open-floating true
      default-floating-position x=50 y=50 relative-to="top-left"
    }
    window-rule {
      match app-id="pavucontrol"
      open-floating true
      default-column-width { fixed 600; }
    }
    window-rule {
      match app-id="nm-connection-editor"
      open-floating true
    }
    window-rule {
      match app-id=r#"org\.gnome\..*"#
      open-floating true
    }
    window-rule {
      geometry-corner-radius 12
      clip-to-geometry true
    }

    // ── Key bindings ─────────────────────────────────────────────────────────
    // Mirrors your GNOME keybindings as closely as possible
    binds {
      // ── Application launchers ──────────────────────────────────────────────
      Mod+Space         { spawn "fuzzel"; }            // like GNOME Activities / dash
      Super+Return      { spawn "wezterm"; }            // terminal (your wezterm)
      Super+E           { spawn "nautilus"; }           // file manager
      Super+B           { spawn "firefox"; }            // browser

      //Toggles overlay for all windows
      Mod+O             { toggle-overview; }

      //Floating mode for window
      Mod+Shift+Space { toggle-window-floating; }
      
      //Show hotkey  overlay
      Mod+Shift+Slash { show-hotkey-overlay; }

      // ── Session ───────────────────────────────────────────────────────────
      Super+L           { spawn "swaylock"; }           // lock screen
      Ctrl+Alt+Delete   { spawn "wlogout"; }            // logout menu
      Super+Shift+Q     { close-window; }              // close window

      // ── Screenshot (matches GNOME screenshot shortcuts) ───────────────────
      Print             { screenshot; }
      Ctrl+Print        { screenshot-screen; }
      Alt+Print         { screenshot-window; }

      // ── Volume / brightness (media keys) ─────────────────────────────────
      XF86AudioRaiseVolume  allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
      XF86AudioLowerVolume  allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
      XF86AudioMute         allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
      XF86AudioPlay         allow-when-locked=true { spawn "playerctl" "play-pause"; }
      XF86AudioNext         allow-when-locked=true { spawn "playerctl" "next"; }
      XF86AudioPrev         allow-when-locked=true { spawn "playerctl" "previous"; }
      XF86MonBrightnessUp   { spawn "brightnessctl" "set" "10%+"; }
      XF86MonBrightnessDown { spawn "brightnessctl" "set" "10%-"; }

      // ── Focus movement (vim-style + arrow keys, like GNOME tiling ext) ────
      Mod+H             { focus-column-left; }
      Mod+L             { focus-column-right; }
      Mod+J             { focus-window-down; }
      Mod+K             { focus-window-up; }
      Mod+Left          { focus-column-or-monitor-left; }
      Mod+Right         { focus-column-or-monitor-right; }
      Mod+Down          { focus-window-down; }
      Mod+Up            { focus-window-up; }

      // ── Move windows ──────────────────────────────────────────────────────
      Mod+Shift+H       { move-column-left; }
      Mod+Shift+L       { move-column-right; }
      Mod+Shift+J       { move-window-down; }
      Mod+Shift+K       { move-window-up; }
      Mod+Shift+Left    { move-column-left; }
      Mod+Shift+Right   { move-column-right; }
      Mod+Shift+Down    { move-window-down; }
      Mod+Shift+Up      { move-window-up; }

      // ── Window sizing ─────────────────────────────────────────────────────
      Mod+R             { switch-preset-column-width; }   // cycle widths
      Mod+F             { maximize-column; }              // Super+Up = maximize in GNOME
      Mod+Shift+F       { fullscreen-window; }
      Mod+C             { center-column; }

      // ── Workspaces (match GNOME Super+number) ─────────────────────────────
      Super+1           { focus-workspace 1; }
      Super+2           { focus-workspace 2; }
      Super+3           { focus-workspace 3; }
      Super+4           { focus-workspace 4; }
      Super+5           { focus-workspace 5; }
      Super+6           { focus-workspace 6; }
      Super+7           { focus-workspace 7; }
      Super+8           { focus-workspace 8; }
      Super+9           { focus-workspace 9; }
      Super+Shift+1     { move-window-to-workspace 1; }
      Super+Shift+2     { move-window-to-workspace 2; }
      Super+Shift+3     { move-window-to-workspace 3; }
      Super+Shift+4     { move-window-to-workspace 4; }
      Super+Shift+5     { move-window-to-workspace 5; }
      Super+Shift+6     { move-window-to-workspace 6; }
      Super+Shift+7     { move-window-to-workspace 7; }
      Super+Shift+8     { move-window-to-workspace 8; }
      Super+Shift+9     { move-window-to-workspace 9; }
      Ctrl+Alt+Left     { focus-workspace-up; }   // GNOME Ctrl+Alt+Left
      Ctrl+Alt+Right    { focus-workspace-down; }

      // ── Clipboard history (replaces clipboard-history GNOME extension) ────
      Super+V           { spawn "sh" "-c" "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"; }

      // ── Overview / niri-specific ──────────────────────────────────────────
      Mod+Tab           { focus-window-or-workspace-down; }
      Mod+Shift+Tab     { focus-window-or-workspace-up; }
      Mod+Comma         { consume-window-into-column; }
      Mod+Period        { expel-window-from-column; }

      // niri quit (emergency)
      Mod+Shift+E       { quit; }
    }
  '';

  # ── Waybar (GNOME-style top panel) ────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = [
      {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;

        modules-left = [
          "niri/workspaces"
          "niri/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "custom/lang"
          "tray"
          "network"
          "pulseaudio"
          "battery"
          "custom/spotify"
          "custom/logout"
        ];

        "niri/workspaces" = {
          format = "{index}";
        };
        "niri/window" = {
          max-length = 50;
        };
        clock = {
          format = " {:%H:%M}";
          format-alt = " {:%A, %d %B %Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt>{calendar}</tt>";
        };
        network = {
          format-wifi = "  {essid}";
          format-ethernet = "󰈀 {ifname}";
          format-disconnected = "󰤭 Offline";
          on-click = "nm-connection-editor";
          tooltip-format = "{ipaddr}";
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 Muted";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "pavucontrol";
        };
        battery = {
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁼"
            "󰁾"
            "󰂀"
            "󰂂"
            "󰁹"
          ];
          states = {
            warning = 30;
            critical = 15;
          };
        };
        tray = {
          spacing = 8;
        };
        "custom/spotify" = {
          exec = "playerctl metadata --format '{{artist}} | {{title}}' 2>/dev/null";
          interval = 2;
          format = "  {}";
          on-click = "playerctl play-pause";
          max-length = 40;
        };
        "custom/logout" = {
          format = "⏻";
          on-click = "wlogout";
          tooltip = false;
        };
        "custom/lang" = {
          exec = ''niri msg keyboard-layouts | awk '/^\s*\*/{if(/English/) print "EN"; else if(/Russian/) print "RU"; else print $NF}' '';
          interval = 1;
          format = "  {}";
          on-click = "niri msg action switch-keyboard-layout next";
        };
      }
    ];

    style = ''
      /* ── Gruvbox dark palette to match your theme ─────────────────────── */
      @define-color bg0     #282828;
      @define-color bg1     #3c3836;
      @define-color bg2     #504945;
      @define-color fg      #ebdbb2;
      @define-color orange  #d65d0e;
      @define-color yellow  #d79921;
      @define-color aqua    #689d6a;
      @define-color blue    #458588;
      @define-color red     #cc241d;

      * {
        font-family: "JetBrainsMono Nerd Font Mono", monospace;
        font-size:   13px;
        border:      none;
        border-radius: 0;
        min-height:  0;
      }

      window#waybar {
        background-color: alpha(@bg0, 0.92);
        color:            @fg;
        border-bottom:    2px solid @orange;
      }

      .modules-left, .modules-center, .modules-right {
        margin: 2px 6px;
      }

      #workspaces button {
        padding:          0 8px;
        background-color: transparent;
        color:            @fg;
        border-radius:    6px;
        margin:           2px 2px;
      }
      #workspaces button.active {
        background-color: @orange;
        color:            @bg0;
        font-weight:      bold;
      }
      #workspaces button:hover {
        background-color: @bg2;
      }

      #clock {
        color:       @yellow;
        font-weight: bold;
      }

      #network, #pulseaudio, #battery, #tray,
      #custom-spotify, #custom-logout {
        padding:          0 10px;
        color:            @fg;
        border-radius:    6px;
        background-color: @bg1;
        margin:           3px 2px;
      }

      #battery.warning  { color: @yellow; }
      #battery.critical { color: @red;    }

      #custom-logout {
        color:            @red;
        font-size:        15px;
      }

      #window {
        color:      @aqua;
        font-style: italic;
      }

      #custom-lang {
        padding:          0 10px;
        color:            @aqua;
        background-color: @bg1;
        border-radius:    6px;
        margin:           3px 2px;
      }
    '';
  };

  # ── Mako (notifications, replaces GNOME's built-in) ──────────────────────────
  services.mako = {
    enable = true;
    package = pkgs.mako;
    settings = {
      # Gruvbox-dark colours
      background-color = "#282828ee";
      text-color = "#ebdbb2";
      border-color = "#d65d0e";
      border-size = 2;
      border-radius = 10;
      font = "JetBrainsMono Nerd Font Mono 11";
      width = 380;
      height = 100;
      margin = "10";
      padding = "12";
      default-timeout = 5000;
      anchor = "top-right";
      layer = "overlay";
      # Sort newest on top (like GNOME)
      sort = "-time";
    };
  };

  # ── swaylock config (lock screen with blur, like GNOME blur extension) ────────
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

  # ── wlogout layout ────────────────────────────────────────────────────────────
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
