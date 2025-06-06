# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/7770c17c-fada-4c24-8023-f6b6fd399a68";
      fsType = "btrfs";
      options = [ "subvol=@nixos/@" "compress=zstd" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/7770c17c-fada-4c24-8023-f6b6fd399a68";
      fsType = "btrfs";
      options = [ "subvol=@nixos/@home" "compress=zstd" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/7770c17c-fada-4c24-8023-f6b6fd399a68";
      fsType = "btrfs";
      options = [ "subvol=@nixos/@nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A6F6-9A37";
      fsType = "vfat";
    };
  
  fileSystems."/persistent" = {
    device = "/dev/disk/by-uuid/7770c17c-fada-4c24-8023-f6b6fd399a68";
    fsType = "btrfs";
    options = [ "subvol=@nixos/@persistent" "compress=zstd" ];
    neededForBoot = true;
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
 networking.networkmanager.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
