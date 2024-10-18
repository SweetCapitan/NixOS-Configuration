{ lib, ... }:
let
  temp-path = builtins.getEnv "HOME";
  defaultString = input: default: if input == "" then default else input;
  #home-path = if temp-path == "" then "/home/dancho/" else temp-path;
  home-path = defaultString temp-path "/home/dancho/";
  config-dir = "${home-path}/.config/syncthing";
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "dancho";
    dataDir = "${home-path}/Documents/";
    configDir = config-dir;
    #cert = "${config-dir}/cert.pem";
    #key = "${config-dir}/key.pem";
    settings = {
      devices = {
        "aeza" = {
          autoAcceptFolders = true;
          id = "E2EJNAT-TY6J2IP-CRM6CKP-7E25O2C-TSDO5VK-4WEVISJ-QH6MMK3-TLXSPAA";
        };
      };
      folders = {
        "Записки" = {
          path = "${home-path}/Documents/Записки";
          devices = [ "aeza" ];
        };
      };
      gui = {
        user = "test";
        password = "test";
      };
    };
  };
}
