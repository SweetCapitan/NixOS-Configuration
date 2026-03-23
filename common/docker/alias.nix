{ config, pkgs, ... }:
{
  programs.bash.shellAliases = {
    docker-ps-compact = ''docker ps --format "{{.Names}} | {{.Image}}\n"'';
  };
}
