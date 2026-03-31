{ pkgs, ... }:

{
  systemd.user.services.valent = {
    description = "Valent Bluetooth Manager";
    wantedBy = [ "default.target" ];
    after = [
      "network.target"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.valent}/bin/valent --gapplication-service";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };
}
