{...}: {
  services.avahi = {
    enable = true;
    hostName = "printer";
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
    nssmdns = true;
  };
}
