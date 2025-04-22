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

      # MQTT configuration
      mqtt = {
        port = 1883;
      };

      # Cluster configuration
      cluster = {
        port = 6222;
      };
    };
  };

  # Фаервол и подготовка директории остаются без изменений
  networking.firewall.allowedTCPPorts = [4222 8222 6222 1883];
  
  systemd.services.nats.preStart = ''
    mkdir -p /var/lib/nats/jetstream
    chown -R nats:nats /var/lib/nats
  '';
}
