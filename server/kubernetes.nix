{
  config,
  pkgs,
  lib,
  ...
}:
let
  kubeMasterIP = "45.151.31.62";
  kubeMasterHostName = "kuber-api.sweetcapitan.ru";
  kubeMasterAPIServerPort = 6443;
in
{
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostName}";

  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    openssl
    cfssl
    certmgr
  ];

  services.kubernetes = {
    roles = [
      "master"
      "node"
    ];
    masterAddress = kubeMasterHostName;
    apiserverAddress = "https://${kubeMasterHostName}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
      enable = true;
    };

    addons.dns.enable = true;
    kubelet.extraOpts = "--fail-swap-on=false";
  };
  systemd.services.etcd.preStart = ''${pkgs.writeShellScript "etcd-wait" ''
    while [ ! -f /var/lib/kubernetes/secrets/etcd.pem ]; do sleep 1; done
  ''}'';
}
