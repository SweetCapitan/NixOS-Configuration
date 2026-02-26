# overlays/opencode-bun-baseline.nix
final: prev:
let
  bunBaseline = prev.stdenvNoCC.mkDerivation rec {
    pname = "bun-baseline";
    version = "1.1.38";

    src = prev.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64-baseline.zip";
      # Run: nix-prefetch-url <url> to get the hash
      hash = "sha256-QSAajF7nSp3Lsc4loRBPH5KYOLV6hFqnjZg3mwznzeI=";
    };

    nativeBuildInputs = [ prev.unzip ];

    unpackPhase = ''
      unzip $src
    '';

    installPhase = ''
      mkdir -p $out/bin
      install -Dm755 bun-linux-x64-baseline/bun $out/bin/bun
    '';

    meta.mainProgram = "bun";
  };
in
{
  opencode = prev.opencode.override {
    bun = bunBaseline;
  };
}
