{
  description = "dancho/sweetcapitan's flake for several machenes working with Awesome NixOS";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs_unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs_unstable";
    };
  };

  outputs =
    inputs@{
      self,
      disko,
      nixpkgs,
      home-manager,
      nixvim,
      ...
    }:
    {
	#homeManagerModules = import ./gnomeExtensions;
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./gnome/settings.nix
          ./configuration.nix
	  ./nixvim.nix
          nixvim.nixosModules.nixvim
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dancho = import ./home.nix;
          }
        ];
      };
      nixosConfigurations.cloud = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          #{ disko.devices.disk.my-disk = "/dev/sda"; }
          ./server/configuration.nix
          ./server/hardware-configuration.nix
        ];
      };
    };
}
