{ pkgs, config, ... }:

{
  services.tailscale = {
    enable = true;
  };
  networking.firewall.allowedTCPPorts = [ 41641 ];
  networking.firewall.allowedUDPPorts = [ 41641 ];
}
