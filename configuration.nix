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
    ./valent.nix
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
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      # Disabled because not work without proxy
      # substituters = [
      #   "https://cache.nixos-cuda.org"
      # ];
      # trusted-public-keys = [
      #   "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      # ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  environment.variables.BROWSER = "zen";

  environment.systemPackages = import ./systemPackages.nix {
    inherit pkgs inputs;
  };
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      home-manager
    ];
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
