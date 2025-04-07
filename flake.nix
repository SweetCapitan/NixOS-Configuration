{
  description = "dancho/sweetcapitan's flake for several machenes working with Awesome NixOS";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs_unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
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
      deploy-rs,
      ...
    }:
    {
      nixosConfigurations."nixos" = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./gnome/settings.nix
          ./configuration.nix
          #          ./nixvim.nix
          #          nixvim.nixosModules.nixvim
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
      nixosConfigurations.printer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          { disko.devices.disk.my-disk = "/dev/sda"; }
          ./printer/configuration.nix
        ];
      };
      #Hey its changes!
      deploy.nodes.cloud_deployrs = {
        hostname = "45.151.31.62";
        profiles.system = {
          user = "dancho";
          remoteBuild = true;
          interactiveSudo = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.cloud;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      colmena = {
        meta = {
          nixpkgs = import nixpkgs { system = "x86_64-linux"; };
          specialArgs = {
            inherit nixpkgs;
          };
        };
        "cloud_colmena" =
          { name, nodes, ... }:
          {
            deployment.tags = [
              "hosting"
              "roflanebalo"
            ];
            deployment.buildOnTarget = true;
            deployment.targetHost = "45.151.31.62";
            deployment.targetUser = "dancho";
            imports = [
              ./server/configuration.nix
              disko.nixosModules.disko
            ];
          };
      };
    };
}
