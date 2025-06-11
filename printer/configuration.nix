# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}:

{
  #  imports = [
  #    # Include the results of the hardware scan.
  #    ./hardware-configuration.nix
  #  ];

  imports = [
    ../server/disk-config.nix
    ./avahi.nix
    #./nats.nix
  ];

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  boot.loader = {
    grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };
  time.timeZone = "Europe/Moscow";

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "dancho"
        "@wheel"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  environment.systemPackages = with pkgs; [
    vim
    curl
    gitMinimal
    htop
  ];

  security.polkit.enable = true;
  services.dbus.enable = true;

  services.klipper = {
    enable = true;
    user = "root";
    group = "root";
    configFile = ./klipper/printer.cfg;
  };

  services.moonraker = {
    user = "root";
    enable = true;
    address = "0.0.0.0";
    settings = {
      octoprint_compat = { };
      history = { };
      authorization = {
        force_logins = true;
        cors_domains = [
          "*.local"
          "*.lan"
          "*://app.fluidd.xyz"
          "*://my.mainsail.xyz"
        ];
        trusted_clients = [
          "10.0.0.0/8"
          "127.0.0.0/8"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "192.168.0.0/24"
          "FE80::/10"
          "::1/128"
        ];
      };
    };
  };

  services.mainsail.enable = true;

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "printer";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        7125
      ];
    };
  };

  services.openssh.enable = true;
  services.nginx.clientMaxBodySize = "1000m";
  services.sshd.enable = true;
  users.users.root.password = "supersecret";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINWborpkRUFYHwNbhJZ6SDwgG7bY+bHJwXlkBTKTk3Ho dancho@nixos"
  ];

  users.mutableUsers = true;

  users.users.dancho = {
    password = "supersecret";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINWborpkRUFYHwNbhJZ6SDwgG7bY+bHJwXlkBTKTk3Ho dancho@nixos"
    ];
    extraGroups = [
      "wheel"
      "input"
      "networkmanager"
    ]; # Enable ‘sudo’ for the user.
  };
  #
  system.stateVersion = "24.11"; # Did you read the comment?

}
