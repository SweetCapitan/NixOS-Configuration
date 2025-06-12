{ config, pkgs, ... }:
{
  services.nats = {
    enable = true;
    
    settings = {
      # Базовые порты
      port = 4222;
      http = 8222;

      # JetStream configuration
      jetstream = {
        store_dir = "/var/lib/nats/jetstream";
        max_file_store = 1073741824;  # 1GB
      };


      # TODO: agenix on printer.host
      authorization = {
        user = "mqtt_iot";
        password = "supersecret";
        timeout = 2;
      };

      # MQTT configuration
      mqtt = {
        port = 1883;
      };

      # Cluster configuration
      # cluster = {
      #   port = 6222;
      #   name = "printer";
      # };
    };
  };

  # Фаервол и подготовка директории остаются без изменений
  networking.firewall.allowedTCPPorts = [4222 8222 6222 1883];
  
  systemd.services.nats.serviceConfig = {
    MemoryMax = "200M";
    CPUQuota = "200%";
    Restart = "on-failure";
    RestartSec = "5s";
  };

  systemd.tmpfiles.rules = [ "d /var/lib/nats 0775 nats nats - -"
    "d /var/lib/nats/jetstream 0755 nats nats - -" 
  ];
}
