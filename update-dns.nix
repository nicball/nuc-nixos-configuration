{ config, pkgs, ... }:

{
  networking.dhcpcd.runHook = ''
    {
      date
      env
      echo
    } >> /var/log/dhcpcd-debug.log
    
    if [ "$reason" = ROUTERADVERT -a "$if_up" = true ]
    then
      /run/current-system/sw/bin/fish ${./update-dns.fish}
    fi
  '';

  environment.systemPackages = [ pkgs.jq ];
}
