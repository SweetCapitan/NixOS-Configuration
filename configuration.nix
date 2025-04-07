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
    ./syncthings.nix
    #TODO: search reason for the problem in the sing-box after 1.9
    ./sing-box-override.nix
    ./common/network/tele2_ttl_change.nix
  ];

  #-------------------------------------------
  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      efiSupport = true;
      device = "nodev";
      enable = true;
    };
  };
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "sing-box-tun" ];
    logRefusedPackets = true;
    logRefusedConnections = true;
    extraCommands = ''
      iptables -A INPUT -j LOG --log-prefix "FIREWALL INPUT: "
      iptables -A FORWARD -j LOG --log-prefix "FIREWALL FORWARD: "
    '';
  };

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
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    sing-box # TODO: remove /usr/share/sing-box/geoip.db
    sing-geoip
    sing-geosite
    nixd
    lua-language-server

    #FONTS
    nerdfonts
    jetbrains-mono
    lazygit
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

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gedit
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-weather # wheater app
      gnome-contacts
      simple-scan
    ]);


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
  users.users.dancho = {
    hashedPasswordFile = "/etc/nixos/hashedPassword";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "input"
      "networkmanager"
      "libvirtd"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      #jetbrains.idea-ultimate
      home-manager
      firefox
      #vim
      #     tree
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}
