{ config, pkgs, ... }:

let
  aria2Config = pkgs.writeText "aria2d.conf" ''
    quiet
    continue
    log=/var/aria2d/.log
    dir=/var/aria2d
    input-file=/var/aria2d/.session
    save-session=/var/aria2d/.session
    save-session-interval=3600
    file-allocation=falloc
    log-level=warn
    max-concurrent-downloads=16
    split=16
    max-connection-per-server=16
    min-split-size=1M
    max-overall-upload-limit=1M
    
    enable-rpc=true
    rpc-listen-all=true
    rpc-secret=${builtins.readFile ./private/aria2d-rpc-secret}
    
    bt-tracker=${builtins.readFile ./bt-trackers.txt}
  '';
in
{
  users.users.aria2d = {
    isSystemUser = true;
    home = "/var/aria2d";
    group = "aria2d";
  };
  users.groups.aria2d = {};

  systemd.services.aria2d = {
    description = "Aria2 Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.aria2}/bin/aria2c --conf-path=${aria2Config}";
      User = "aria2d";
      Group = "aria2d";
    };
  };

  networking.firewall.allowedTCPPorts = [ 6800 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 6881; to = 6999; } ];
}
