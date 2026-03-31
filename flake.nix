{
  description = "dancho/sweetcapitan's flake for several machenes working with Awesome NixOS";

  # Shell selection: "dms", "noctalia", or "none" (default)
  # This determines which desktop shell to use (DankMaterialShell or Noctalia Shell)
  # When set to "none", uses default waybar + mako setup
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs_unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
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
      agenix,
      impermanence,
      nixpkgs_unstable,
      dms,
      dgop,
      noctalia-qs,
      noctalia,
      ...
    }:
    let
      shellSelection = "dms"; # Options: "dms", "noctalia", "none"
    in
    {
      nixosConfigurations."nixos" = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./gnome/settings.nix
          ./niri/system.nix
          ./configuration.nix
          #          ./nixvim.nix
          #          nixvim.nixosModules.nixvim
          impermanence.nixosModules.impermanence
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              shellSelection = shellSelection;
            };
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
          #{ disko.devices.disk.my-disk = "/dev/sda"; }
          ./printer/configuration.nix
          ./printer/hardware-configuration.nix
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
