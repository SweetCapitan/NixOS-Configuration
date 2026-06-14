nixpkgs_unstable: final: prev:
let
  opencodeUnstable = nixpkgs_unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.opencode;
in
{
  opencode = opencodeUnstable.override {
    bun = final.bun; # picks up baseline bun from bun-baseline.nix overlay
  };
}
