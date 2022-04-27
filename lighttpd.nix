{ config, pkgs, ... }:

{
  services.lighttpd = {
    enable = true;
    # mod_userdir = true;
    enableModules = [ "mod_cgi" "mod_alias" ];
    extraConfig = ''
      cgi.assign = (
        ".sh"  => "/run/current-system/sw/bin/bash",
        ".fish"  => "/run/current-system/sw/bin/fish",
      )

      # userdir.exclude-user = ( "root", "postmaster" )

      $HTTP["url"] =~ "^/files(/|$)" {
        alias.url += ( "/files" => "/var/aria2d" )
        dir-listing.activate = "enable"
        dir-listing.encoding = "utf-8"
      }

      server.breakagelog = "/tmp/lighttpd-breakage.log"
    '';
  };
  users.users.lighttpd.extraGroups = [ "systemd-journal" ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
