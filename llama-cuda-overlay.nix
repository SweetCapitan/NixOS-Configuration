nixpkgs_unstable_small: final: prev:
let
  pkgs_unstable_small = import nixpkgs_unstable_small {
    system = prev.stdenv.hostPlatform.system;
    config.allowUnfree = true;
    config.cudaSupport = true;
  };
  llama-cpp-unstable = pkgs_unstable_small.llama-cpp;
in
{
  llama-cpp = llama-cpp-unstable.overrideAttrs (old: {
    cmakeFlags =
      (builtins.filter (
        f: !(builtins.isString f && prev.lib.hasPrefix "-DCMAKE_CUDA_ARCHITECTURES" f)
      ) old.cmakeFlags)
      ++ [ "-DCMAKE_CUDA_ARCHITECTURES=61" ];
  });
}
