nixpkgs_unstable_small: final: prev:
let
  pkgs_unstable_small = import nixpkgs_unstable_small {
    system = prev.stdenv.hostPlatform.system;
    config.allowUnfree = true;
    config.cudaSupport = true;
    config.cudaCapabilities = [ "6.1" ];
    config.allowUnsupportedSystem = true;
    config.cudaForwardCompat = false;
    # config.cudaPackages = "cudaPackages_12_9";
  };

  cudaPackages = prev.cudaPackages_12_9.overrideScope (
    cFinal: cPrev: {
      flags = cPrev.flags // {
        cmakeCudaArchitecturesString = "61";
      };
    }
  );
in
{
  llama-cpp =
    (pkgs_unstable_small.llama-cpp.override {
      cudaSupport = true; # explicit override
      cudaPackages = cudaPackages;
    }).overrideAttrs
      (old: {
        cmakeFlags = (builtins.filter (f: builtins.match ".*GGML_NATIVE.*" f == null) old.cmakeFlags) ++ [
          "-DGGML_NATIVE=ON"
          "-DGGML_BACKEND_DL=ON"
          "-DGGML_CPU_ALL_VARIANTS=ON"
          "-DGGML_LTO=ON"
        ];
      });
}
