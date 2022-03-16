{ config, pkgs, ... }:

{
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard.enable = true;
  networking.wireguard.interfaces.wg0 = {
    listenPort = 51820;
    privateKey = builtins.readFile ./private/wireguard-private-key;
    ips = [ "10.42.42.42/8" ];
    peers = [
      { allowedIPs = [ "10.42.42.24/32" ]; publicKey = "TmodaOYsiWFvGM21mQ08OfmxFmacowmzm6krXVArtEk="; }
      { allowedIPs = [ "10.42.42.66/32" ]; publicKey = "Lp2aYaQ76naQslTjvj/4tt9Oo7MYIBSvHJUm2wSsfh8="; }
    ];
  };
}
