## View how flake inputs can affects whole system. 
Its also valid for basic config changes
nix flake update <flake_input>            # update lock file
sudo nixos-rebuild build --flake .#hostname   # build only
nix run nixpkgs#nvd -- diff /run/current-system ./result  # review changes
sudo nixos-rebuild switch --flake .#hostname  # apply if happy
