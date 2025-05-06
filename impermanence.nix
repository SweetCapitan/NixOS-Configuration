{ ... }:
{
  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/etc/nixos/"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/etc/NetworkManager"
      "/var/lib/systemd/coredump"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    files = [
      "/etc/machine-id"
    ];
    users.dancho = {
      directories = [
        {
          directory = ".ssh";
          mode = "0700";
        }
        "Configurations"
        "Downloads"
        "Pictures"
        "Documents"
        # ".mozilla/firefox"
        # ".cache/mozilla"
        # ".config/mozilla"
      ];
      # files = [
      #   ".bashrc"
      # ];
    };
  };
}
