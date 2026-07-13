{ pkgs, ... }: {
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
  systemd.services.avahi-daemon = {
    serviceConfig = {
      # Fixes avahi-daemon crying about an existing PID file after unclean shutdowns
      ExecStartPre = "${pkgs.coreutils}/bin/rm -f /run/avahi-daemon/pid";
    };
  };

}
