#Edt this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nvim/neovim.nix
    # ./syncthings.nix # disabled
    #currently not needed :D
    ./common/network/tele2_ttl_change.nix
    ./avahi.nix
    ./project_mayhem_service.nix
    ./impermanence.nix
    ./valent.nix
  ];

  #-------------------------------------------
  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  boot.loader = {
    efi = {
      #canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      efiSupport = true;
      device = "nodev";
      efiInstallAsRemovable = true;
      enable = true;
    };
  };
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "sing-box-tun" ];
    logRefusedPackets = true;
    logRefusedConnections = true;
    checkReversePath = "loose"; # todo: after update sing-box to 1.11 remove this
    allowedTCPPorts = [ 9 ];
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  services.flatpak.enable = true;
  services.tele2TTLChanger.enable = false;
  #boot.kernel.sysctl = {
  #"net.ipv4.ip_forward" = 1;
  #};
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };
  programs.bash.shellAliases = {
    sbr = "sudo sing-box run --config /etc/nixos/configt.json";
    nrt = "sudo nixos-rebuild test --flake ~/Configurations/#nixos";
    nrs = "sudo nixos-rebuild switch --flake ~/Configurations/#nixos";
  };
  time.timeZone = "Europe/Moscow";
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    supportedLocales = [
      "en_GB.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
  };

  #boot.loader.grub.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      AllowUsers = [
        "root"
        "dancho"
      ];
      PasswordAuthentication = true;
      UseDns = false;
      X11Forwarding = false;
      PermitRootLogin = "yes";
    };
  };

  programs.ssh = {
    extraConfig = ''
      Host cloud-ru
          HostName 45.151.31.62
          User dancho
          Port 22
          ForwardAgent yes
          IdentityFile ~/.ssh/cloud-nix-key
      Host aeza-ru
          HostName 5.42.78.198
          User root
          Port 22
          ForwardAgent yes
          IdentityFile ~/.ssh/aeza-key
    '';
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    sing-box # TODO: remove /usr/share/sing-box/geoip.db
    sing-geoip
    sing-geosite
    nixd
    lua-language-server

    #FONTS - removed nerdfonts in 25.11 (use specific fonts)
    #nerd-fonts.jetbrains-mono
    lazygit

    spotify
    wireshark
    dconf-editor
    orca-slicer
    podman-compose

    xclip
    opencode
    bun
    crush
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    valent
  ];
  #programs.nixvim.enable = true;
  #programs.neovim = {
  #	enable = true;
  #	viAlias = true;
  #	vimAlias = true;
  #	configure = {
  #		customRC = ''
  #			set equalprg=nixfmt\
  #			'';
  #	};
  #};

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  environment.gnome.excludePackages = (
    with pkgs;
    [
      gnome-photos
      gnome-tour
      gedit
      cheese # webcam tool - moved to top-level in 25.11
      gnome-music # moved to top-level in 25.11
      gnome-terminal # moved to top-level in 25.11
      epiphany # web browser - moved to top-level in 25.11
      geary # email reader - moved to top-level in 25.11
      evince # document viewer - moved to top-level in 25.11
      gnome-characters # moved to top-level in 25.11
      totem # video player - moved to top-level in 25.11
      gnome-weather # moved to top-level in 25.11
      gnome-contacts # moved to top-level in 25.11
      simple-scan # moved to top-level in 25.11
      tali # poker game - moved to top-level in 25.11
      iagno # go game - moved to top-level in 25.11
      hitori # sudoku game - moved to top-level in 25.11
      atomix # puzzle game - moved to top-level in 25.11
    ]
  );
  # Remaining games still in pkgs.gnome:
  # (none currently - all moved)

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # programs.hyprland = {
  #    enable = true;
  #    xwayland.enable = true;
  #    nvidiaPatches = true;
  #  };
  nixpkgs.config.allowUnfree = true;

  #  hardware = {
  #    opengl.enable = true;
  #    nvidia.modesetting.enable = true;
  #  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  nixpkgs.overlays = [
    (import ./opencode-bun-baseline.nix inputs.nixpkgs_unstable)
  ];

  networking = {
    interfaces = {
      enp7s0 = {
        wakeOnLan = {
          enable = true;
          policy = [ "magic" ];
        };
      };
    };
  };

  users.users.dancho = {
    hashedPasswordFile = "/etc/nixos/hashedPassword";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "input"
      "networkmanager"
      "libvirtd"
      "podman"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      #jetbrains.idea-ultimate
      home-manager
      firefox
      #vim
      #     tree
    ];
  };

  system.stateVersion = "23.11"; # Did you read the comment?

}
