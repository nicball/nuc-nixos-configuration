{ config, pkgs, ... }:

{
  systemd.services.clash = {
    description = "Clash Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.clash}/bin/clash -f ${./private/clash-config.yaml} -d /var/clash";
    };
  };
}
