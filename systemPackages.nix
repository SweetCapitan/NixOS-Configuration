{
  pkgs,
  inputs,
  unstable,
  ...
}:
with pkgs;
[
  nixfmt-rfc-style
  sing-box # TODO: remove /usr/share/sing-box/geoip.db
  sing-geosite
  nixd
  lua-language-server

  lazygit
  nautilus
  gparted
  baobab

  xwayland-satellite
  jdk25
  gnome-text-editor
  lutris
  nh
  vkbasalt
  zls
  zig

  distrobox
  distroshelf
  busybox
  winboat

  simple-scan
  valent

  inputs.vm-curator.packages.${pkgs.system}.default

  spotify
  wireshark
  unstable.orca-slicer
  plasticity
  freecad-wayland
  podman-compose

  xclip
  opencode
  pi-coding-agent
  bun
  inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

  bibata-cursors
  papirus-folders
  gtk3
  gtk4
  gtk2
  adw-gtk3

  cudatoolkit
  llama-cpp
  mcporter
  nvtopPackages.nvidia
  # unstable.llama-cpp-vulkan
  # pyright
  basedpyright
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
