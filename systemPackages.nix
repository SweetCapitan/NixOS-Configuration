{ pkgs, inputs }: with pkgs;
[
  nixfmt-rfc-style
  sing-box # TODO: remove /usr/share/sing-box/geoip.db
  sing-geosite
  nixd
  lua-language-server

  lazygit

  spotify
  wireshark
  orca-slicer
  podman-compose

  xclip
  opencode
  pi-coding-agent
  bun
  crush
  inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  valent

  cudatoolkit
  llama-cpp
  nvtopPackages.nvidia
  # unstable.llama-cpp-vulkan
  pyright
  ruff
  isort
  fzf
  fd
  ripgrep
  tree-sitter
  cups-pk-helper
  edac-utils # sudo edac-util -v
  vulkan-tools # даст vulkaninfo
]
