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
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
#    ../common/users/dancho.nix
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

  networking.hostName = "cloud-ru"; # Define your hostname.

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
    vim
    curl
    gitMinimal
    htop
  ];

  nixpkgs.config.allowUnfree = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
    ];
  };
  services.openssh.enable = true;
  services.sshd.enable = true;
  users.users.root.password = "supersecret";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINWborpkRUFYHwNbhJZ6SDwgG7bY+bHJwXlkBTKTk3Ho dancho@nixos"
  ];

  users.users.dancho.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINWborpkRUFYHwNbhJZ6SDwgG7bY+bHJwXlkBTKTk3Ho dancho@nixos"
  ];

  users.users.dancho = {
      hashedPasswordFile = "/etc/nixos/hashedPassword";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "input"
        "networkmanager"
      ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [ ];
    };

  #
  system.stateVersion = "23.11"; # Did you read the comment?

}
