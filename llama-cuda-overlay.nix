nixpkgs_unstable_small: final: prev:
let
  pkgs_unstable_small = import nixpkgs_unstable_small {
    system = prev.stdenv.hostPlatform.system;
    config.allowUnfree = true;
    config.cudaSupport = true;
    config.blasSupport = true;
    config.rocmSupport = false;
    config.metalSupport = false;
    config.cudaCapabilities = [ "6.1" ];
    config.allowUnsupportedSystem = true;
    config.cudaForwardCompat = false;
  };

  cudaPackages = pkgs_unstable_small.cudaPackages_12.overrideScope (
    cFinal: cPrev: {
      flags = cPrev.flags // {
        cmakeCudaArchitecturesString = "61";
      };
      cuda_compat = null;
    }
  );
in
{
  llama-cpp =
    (pkgs_unstable_small.llama-cpp.override {
      cudaSupport = true;
      inherit cudaPackages;
    }).overrideAttrs
      (old: {
        cmakeFlags = (builtins.filter (f: builtins.match ".*GGML_NATIVE.*" f == null) old.cmakeFlags) ++ [
          "-DGGML_NATIVE=ON"
          "-DGGML_LTO=ON"
        ];
        preConfigure = ''
          export NIX_ENFORCE_NO_NATIVE=0
          ${old.preConfigure or ""}
        '';
      });
}
