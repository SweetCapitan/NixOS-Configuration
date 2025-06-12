{ lib, pkgs, config, age, ... }:

let
in {
  age.identityPaths = ["/home/dancho/.ssh/aeza_old"];
  age.secrets.secret1 = {
    file = ./secrets/secret1.age;
    owner = "dancho";
  };
  # Systemd-сервис
  systemd.services.project_mayhem = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${config.age.secrets.secret1.path}";
      User = "dancho";
    };
  };

  # Таймер
  systemd.timers.project_mayhem = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "30d";
      Persistent = true;
    };
  };
}
