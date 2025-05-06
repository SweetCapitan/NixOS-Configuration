{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.tele2TTLChanger;
in
{
  options = {
    services.tele2TTLChanger = {
      enable = mkEnableOption "обход блокировки раздачи интернета Tele2 через изменение TTL";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.tele2_ttl_changer = {
      description = "Обход блокировки раздачи интернета Tele2 по TTL";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "${pkgs.iptables}/bin/iptables -t mangle -A POSTROUTING -j TTL --ttl-set 65";
      };
    };
  };
}