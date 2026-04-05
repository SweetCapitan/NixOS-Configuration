nixpkgs_unstable: final: prev:
let
  bunBaseline = prev.stdenvNoCC.mkDerivation rec {
    pname = "bun-baseline";
    version = "1.3.3";

    src = prev.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64-baseline.zip";
      hash = "sha256-KB5sutlp6y9e9XJMbLoB2kDNX+rW+CksUO1gvU26eK4=";
    };

    sourceRoot = "bun-linux-x64-baseline";
    strictDeps = true;

    nativeBuildInputs = [
      prev.unzip
      prev.autoPatchelfHook # same as upstream
    ];
    buildInputs = [ prev.openssl ]; # same as upstream

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 ./bun $out/bin/bun
      ln -s $out/bin/bun $out/bin/bunx
      runHook postInstall
    '';

    meta.mainProgram = "bun";
  };
  opencodeUnstable = nixpkgs_unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.opencode;
in
{
  bun = bunBaseline;

  opencode = opencodeUnstable.override {
    bun = bunBaseline;
  };
}
