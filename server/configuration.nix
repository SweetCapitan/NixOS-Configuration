# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
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
     ];


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

  time.timeZone = "Europe/Moscow";

  networking.hostName = "nixos"; # Define your hostname.

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
  ];

  environment.systemPackages = map lib.lowPrio [
      pkgs.curl
      pkgs.gitMinimal
    ];

  nixpkgs.config.allowUnfree = true;

   services.openssh.enable = true;
   users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE1K50JhWnVMR1kSpSRnFmYDX5elbZx3YSb4MB9LG9sW dancho@arch"
   ];

  #
  system.stateVersion = "23.11"; # Did you read the comment?

}
