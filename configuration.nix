{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
# let
#   llama-docker =
#     (import ./llama-image.nix {
#       inherit pkgs;
#       llama-pkg = pkgs.llama-cpp;
#     }).dockerImage;
# in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./nvim/neovim.nix
    # ./syncthings.nix # disabled
    #currently not needed :D
    ./common/network/tele2_ttl_change.nix
    ./avahi.nix
    ./project_mayhem_service.nix
    ./impermanence.nix
    ./dms/nixosModules.nix
  ];

  # systemd.user.services.load-llama-image = {
  #   description = "Load llama-server image into user podman";
  #   wantedBy = [ "default.target" ];
  #   script = ''
  #     if ! ${pkgs.podman}/bin/podman image exists localhost/llama-server:latest; then
  #       ${pkgs.podman}/bin/podman load -i ${llama-docker}
  #     fi
  #   '';
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #   };
  # };

  boot.kernelParams = [ "mitigations=off" ];

  environment.etc."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=adw-gtk3
    gtk-application-prefer-dark-theme=0
  '';

  boot.kernelPackages = pkgs.linuxPackages_6_12; # setup later lts version or 6.18.
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

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  programs.gamescope = {
    enable = true;
    # capSysNice = true;
  };

  services.udev.extraRules = ''
    # For NVMe SSDs (System): disable the scheduler (none).
    # NVMe is so fast that the kernel scheduler queues are wasting old CPU cycles.
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"

    # For HDD (Games): hard-code the BFQ scheduler.
    # BFQ (Budget Fair Queueing) groups requests and prevents background processes from
    # stealing the game's read thread. Texture loading will be prioritized.
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    # HDD tweak: Increase the read-ahead size to 4MB (4096 KB).
    # This will force the drive to read data "with reserve" in large linear chunks, which is much easier on an HDD.
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/read_ahead_kb}="4096"
  '';

  environment.sessionVariables = {
    # Forces XWayland and third-party libraries to properly initialize EGL on NVIDIA
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Critical line to fix "eglInitialize() failed" in containers:
    EGLECON_DRIVERS_PATH = "/run/opengl-driver/share/egl/egl_external_platform.d";
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      splix
      samsung-unified-linux-driver
    ];
  };

  hardware.printers = {
    ensureDefaultPrinter = "Samsung_SCX-3200";
    ensurePrinters = [
      {
        name = "Samsung_SCX-3200";
        description = "Samsung SCX-3200 Series";
        deviceUri = "usb://Samsung/SCX-3200%20Series?serial=Z5L4BFEB501784X&interface=1";
        model = "samsung/scx3200.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
  };

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      samsung-unified-linux-driver
    ];
  };

  programs.xwayland.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/3C2438202437DB98";
    fsType = "ntfs3";
    options = [
      "uid=1000"
      "gid=1000"
      "fmask=0022"
      "dmask=0011"
      "nofail"
      "noatime"
      "async"
      # "windows_names"
      # "ignore_case"
    ];
  };

  programs.gamemode.enable = true;
  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };
  hardware.nvidia-container-toolkit.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "sing-box-tun" ];
    logRefusedPackets = true;
    logRefusedConnections = true;
    checkReversePath = "loose"; # todo: after update sing-box to 1.11 remove this
    allowedTCPPorts = [ 9 ];
    # for valent
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  environment.sessionVariables = {
    GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];
  };

  services.flatpak.enable = false;
  services.tele2TTLChanger.enable = false;
  #boot.kernel.sysctl = {
  #"net.ipv4.ip_forward" = 1;
  #};
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

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "dancho"
        "@wheel"
      ];
      auto-optimise-store = true;
      substituters = [
        # Disabled because not work without proxy
        #   "https://cache.nixos-cuda.org"
        "https://cache.nixos.org"
        # "https://install.determinate.systems"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        # "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        #   "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];

    };
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    package = pkgs.lix;

    # disabled because we use nh clean
    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-older-than 30d";
    # };
  };

  programs.nh.clean = {
    enable = true;
    extraArgs = "--keep 5 --keep-since 3d --optimise";
    dates = "weekly";
  };

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  environment.variables.BROWSER = "zen";

  environment.systemPackages =
    let
      unstable = import inputs.nixpkgs_unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config = {
          allowUnfree = true;
        };
      };
    in
    import ./systemPackages.nix {
      inherit pkgs inputs unstable;
    };
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark-qt;
  };
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (import ./bun-baseline.nix)
    (import ./opencode-unstable.nix inputs.nixpkgs_unstable)
    (import ./llama-cuda-overlay.nix inputs.nixpkgs_unstable_small)
    inputs.pi.overlays.default
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
      "wireshark"
      "scanner"
      "lp"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      home-manager
    ];
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
