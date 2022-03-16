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
    file-allocation=none
    log-level=warn
    max-concurrent-downloads=16
    split=16
    max-connection-per-server=16
    min-split-size=1M
    max-overall-upload-limit=1M
    
    enable-rpc=true
    rpc-listen-all=true
    rpc-secret=${builtins.readFile ./private/aria2d-rpc-secret}
    
    bt-tracker=http://bt.rghost.net:80/announce,http://carbon-bonsai-621.appspot.com:80/announce,http://explodie.org:6969/announce,http://googer.cc:1337/announce,http://h4.trakx.nibba.trade:80/announce,http://kinorun.com:80/announce.php,http://milanesitracker.tekcities.com:80/announce,http://nyaa.tracker.wf:7777/announce,http://opentracker.xyz:80/announce,http://share.camoe.cn:8080/announce,http://siambit.com:80/announce.php,http://t.nyaatracker.com:80/announce,http://torrent-team.net:80/announce.php,http://torrent.nwps.ws:80/announce,http://torrentzilla.org:80/announce,http://torrentzilla.org:80/announce.php,http://tr.cili001.com:8070/announce,http://tracker-cdn.moeking.me:2095/announce,http://tracker.etree.org:6969/announce,http://tracker.files.fm:6969/announce,http://tracker.ipv6tracker.org:80/announce,http://tracker.ipv6tracker.ru:80/announce,http://tracker.tfile.me:80/announce,http://tracker.trackerfix.com:80/announce,http://vps02.net.orel.ru:80/announce,http://www.shnflac.net:80/announce.php,http://www.zone-torrent.net:80/announce.php,https://carbon-bonsai-621.appspot.com:443/announce,https://mytracker.fly.dev:443/announce,https://opentracker.xyz:443/announce,https://tr.torland.ga:443/announce,https://tracker.coalition.space:443/announce,https://tracker.lilithraws.cf:443/announce,https://tracker.nitrix.me:443/announce,https://tracker.tamersunion.org:443/announce,https://trakx.herokuapp.com:443/announce,udp://6ahddutb1ucc3cp.ru:6969/announce,udp://9.rarbg.com:2810/announce,udp://9.rarbg.com:2950/announce,udp://9.rarbg.me:2710/announce,udp://9.rarbg.to:2710/announce,udp://bt.yui.cat:55268/announce,udp://bubu.mapfactor.com:6969/announce,udp://code2chicken.nl:6969/announce,udp://discord.heihachi.pw:6969/announce,udp://engplus.ru:6969/announce,udp://exodus.desync.com:6969/announce,udp://explodie.org:6969/announce,udp://fe.dealclub.de:6969/announce,udp://inferno.demonoid.is:3391/announce,udp://ipv6.tracker.zerobytes.xyz:16661/announce,udp://mail.realliferpg.de:6969/announce,udp://movies.zsw.ca:6969/announce,udp://mts.tvbit.co:6969/announce,udp://open.demonii.com:1337/announce,udp://open.stealth.si:80/announce,udp://opentor.org:2710/announce,udp://opentracker.i2p.rocks:6969/announce,udp://p4p.arenabg.com:1337/announce,udp://pow7.com:80/announce,udp://retracker.lanta-net.ru:2710/announce,udp://retracker.netbynet.ru:2710/announce,udp://thetracker.org:80/announce,udp://torrentclub.online:54123/announce,udp://tracker.0x.tf:6969/announce,udp://tracker.altrosky.nl:6969/announce,udp://tracker.army:6969/announce,udp://tracker.beeimg.com:6969/announce,udp://tracker.birkenwald.de:6969/announce,udp://tracker.blacksparrowmedia.net:6969/announce,udp://tracker.cyberia.is:6969/announce,udp://tracker.dler.org:6969/announce,udp://tracker.leech.ie:1337/announce,udp://tracker.lelux.fi:6969/announce,udp://tracker.moeking.me:6969/announce,udp://tracker.nrx.me:6969/announce,udp://tracker.ololosh.space:6969/announce,udp://tracker.openbittorrent.com:6969/announce,udp://tracker.opentrackr.org:1337/announce,udp://tracker.theoks.net:6969/announce,udp://tracker.tiny-vps.com:6969/announce,udp://tracker.torrent.eu.org:451/announce,udp://tracker.uw0.xyz:6969/announce,udp://tracker.zerobytes.xyz:1337/announce,udp://tracker0.ufibox.com:6969/announce,udp://tracker1.bt.moack.co.kr:80/announce,udp://tracker2.dler.com:80/announce,udp://tracker4.itzmx.com:2710/announce,udp://tracker6.lelux.fi:6969/announce,udp://udp-tracker.shittyurl.org:6969/announce,udp://vibe.community:6969/announce,udp://vibe.sleepyinternetfun.xyz:1738/announce,udp://wassermann.online:6969/announce,udp://www.torrent.eu.org:451/announce
  '';
in
  {
    users.users.aria2d = {
      isSystemUser = true;
      home = "/var/aria2d";
      group = "aria2d";
    };
    users.groups.aria2d = {};
  
    environment.systemPackages = [ pkgs.aria2 ];
  
    systemd.services.aria2d = {
      description = "Aria2 Daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "/run/current-system/sw/bin/aria2c --conf-path=${aria2Config}";
        User = "aria2d";
        Group = "aria2d";
      };
    };
  
    networking.firewall.allowedTCPPorts = [ 6800 ];
  }
