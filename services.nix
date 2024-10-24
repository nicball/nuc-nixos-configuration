{ config, pkgs, lib, ... }:

let
  sandboxing-config = {
    NoNewPrivileges = true;
    PrivateTmp = true;
    PrivateDevices = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    ProtectControlGroups = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
    RestrictRealtime = true;
    RestrictNamespaces = true;
    MemoryDenyWriteExecute = true;
  };
in

{
  systemd.services.mautrix-telegram = {
    description = "Mautrix Telegram Bridge";
    after = [ "synapse.service" ];
    partOf = [ "synapse.service" ];
    requires = [ "synapse.service" ];
    serviceConfig = sandboxing-config // {
      Restart = "always";
      DynamicUser = "true";
      StateDirectory = "mautrix-telegram";
      ExecStart =
        let
          py = pkgs.python3.withPackages (p: with p; [ pysocks pkgs.mautrix-telegram ]);
        in
        "${py}/bin/python3 -m mautrix_telegram";
      WorkingDirectory = "/var/lib/mautrix-telegram";
    };
    wantedBy = [ "multi-user.target" ];
  };
  nixpkgs.config.permittedInsecurePackages = [ "olm-3.2.16" ];

  # systemd.user.services.matrix-qq = {
  #   Unit = {
  #     Description = "Mautrix Telegram Bridge";
  #     After = [ "synapse.service" "qsign.service" ];
  #     PartOf = [ "synapse.service" ];
  #     Requires = [ "synapse.service" "qsign.service" ];
  #   };
  #   serviceConfig = {
  #     ExecStart = "${pkgs.matrix-qq}/bin/matrix-qq";
  #     WorkingDirectory = "${config.home.homeDirectory + "/matrix-qq"}";
  #   };
  #   Install.WantedBy = [ "default.target" ];
  # };

  # systemd.user.services.qsign = {
  #   Unit = {
  #     Description = "QQ signing server";
  #     PartOf = [ "matrix-qq.service" ];
  #   };
  #   serviceConfig = {
  #     ExecStart = "${pkgs.jre}/bin/java -jar ./unidbg-fetch-qsign-1.2.1-all.jar --basePath=./txlib/8.9.63";
  #     WorkingDirectory = config.home.homeDirectory + "/qsign";
  #   };
  # };

  systemd.services.synapse = {
    description = "Synapse Matrix Home Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = sandboxing-config // {
      Restart = "always";
      DynamicUser = "true";
      StateDirectory = "synapse";
      ExecStart = "${pkgs.matrix-synapse}/bin/synapse_homeserver -c home_server.yaml";
      WorkingDirectory = "/var/lib/synapse";
    };
  };

  # systemd.user.services.minecraft = {
  #   description = "Minecraft Server";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     WorkingDirectory = "${config.home.homeDirectory + "/mc"}";
  #     ExecStart = "${pkgs.tmux}/bin/tmux new -s minecraft -d '${pkgs.jre_headless}/bin/java -Dhttp.proxyHost=127.0.0.1 -Dhttp.proxyPort=7890 -Dhttps.proxyHost=127.0.0.1 -Dhttps.proxyPort=7890 -Xmx3072M -jar ./fabric*.jar nogui'";
  #     ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t minecraft";
  #     RemainAfterExit = true;
  #   };
  #   Install.WantedBy = [ "default.target" ];
  # };

  # systemd.user.services.frpc = {
  #   description = "Fast Reverse Proxy Client";
  #   Service.ExecStart = "${pkgs.frp}/bin/frpc -c ${./private/frpc.ini}";
  #   Install.WantedBy = [ "default.target" ];
  # };

  systemd.services.cloudflared = {
    description = "Cloudflare Argo Tunnel";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = sandboxing-config // {
      DynamicUser = true;
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token ${import ./private/cloudflared-token.nix}";
      Restart = "always";
      WorkingDirectory = "/empty";
    };
  };

  systemd.services.caddy =
    let configFile = pkgs.writeText "caddy-config" ''
      :8080
      file_server browse
      root * /srv/www
    '';
    in {
      description = "Caddy HTTP Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = sandboxing-config // {
        ExecStart = "${pkgs.caddy}/bin/caddy run --adapter caddyfile --config ${configFile}";
        WorkingDirectory = "/empty";
      };
    };

  # systemd.user.services.fvckbot = {
  #   description = "Yet another telegram bot";
  #   serviceConfig = {
  #     ExecStart = "${pkgs.fvckbot}/bin/fvckbot";
  #     WorkingDirectory = "${config.home.homeDirectory + "/fvckbot"}";
  #     Environment = [
  #       "TG_BOT_TOKEN=${import ./private/fvckbot-token.nix}"
  #       "https_proxy=http://localhost:7890"
  #     ];
  #   };
  #   Install.WantedBy = [ "default.target" ];
  # };

  # systemd.user.services.transfersh = {
  #   description = "Easy and fast file sharing from the command-line";
  #   serviceConfig = {
  #     ExecStart = "${pkg.tranfersh}/bin/transfer.sh";
  #     Environment = [
  #       "LISTENER=:8081"
  #       "TEMP_PATH=/tmp/"
  #       "PROVIDER=local"
  #       "BASEDIR=${config.home.homeDirectory + "/transfersh"}"
  #       "LOG=${config.home.homeDirectory + "/transfersh/.log"}"
  #     ];
  #   };
  #   Install.WantedBy = [ "default.target" ];
  # };

  nic.instaepub = {
    enable = true;
    output-dir = "/srv/www/instaepub";
    auto-archive = true;
    interval = "hourly";
    pandoc = pkgs.pandoc-static;
  } // import ./private/instaepub.nix;
  systemd.services.instaepub.serviceConfig = {
    User = "nicball";
    Group = "users";
  };

  nic.cloudflare-ddns = {
    enable = true;
    enable-log = true;
    log-path = "/tmp/cloudflare-ddns.log";
  } // import ./private/cloudflare-ddns.nix;

  systemd.services.aria2d = {
    description = "Aria2 Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = sandboxing-config // {
      ProtectSystem = "full";
      User = "nicball";
      Group = "users";
      ExecStart =
        let
          aria2 = pkgs.aria2.override ({
            server-mode = true;
            dir = "/srv/www/files";
          } // import ./private/aria2d.nix);
        in
        "${aria2}/bin/aria2c";
    };
  };

  systemd.services.crawler = {
    description = "Web Crawler";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = sandboxing-config // {
      DynamicUser = true;
      StateDirectory = "16k-crawler";
      ExecStart = "${pkgs.python3.withPackages (p: [ p.requests ])}/bin/python3 bot.py";
      WorkingDirectory = "/var/lib/16k-crawler";
    };
  };

  systemd.timers.crawler = {
    description = "Timer for Web Crawler";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "hourly";
  };

  systemd.services.nodebb = {
    description = "NodeBB forum";
    requires = [ "redis-nodebb.service" ];
    after = [ "redis-nodebb.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "nodebb";
      Environment = "PATH=${pkgs.nodejs}/bin";
      ExecStart = "/var/lib/nodebb/nodebb start";
      ExecStop = "/var/lib/nodebb/nodebb stop";
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/var/lib/nodebb";
    };
  };

  services.redis.servers.nodebb.enable = true;

}
