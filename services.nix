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

  make-service = { sandboxing ? true, dir ? null, dynamic-user ? true, proxy ? false, ... }@args:
    let
      merge = lib.foldl' lib.recursiveUpdate {};
      passthru = lib.filterAttrs (k: v: !builtins.hasAttr k (lib.functionArgs make-service)) args;
    in
    merge [
      (lib.optionalAttrs sandboxing {
        serviceConfig = sandboxing-config;
      })
      (lib.optionalAttrs dynamic-user {
        serviceConfig.DynamicUser = true;
      })
      (lib.optionalAttrs (dir != null) {
        serviceConfig = {
          StateDirectory = dir;
          WorkingDirectory = "/var/lib/" + dir;
        };
      })
      (lib.optionalAttrs proxy {
        environment = config.networking.proxy.envVars;
      })
      ({
        serviceConfig.Restart = "always";
        wantedBy = [ "multi-user.target" ];
      })
      passthru
    ];

in

{
  # imports = [ ./factorio.nix ];

  systemd.services.clash = make-service {
    description = "Clash Daemon";
    dir = "clash";
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.clash-meta}/bin/clash-meta -f ${./private/clash.yaml} -d /var/lib/clash > /dev/null 2>&1";
    };
  };

  systemd.services.mautrix-telegram = make-service {
    description = "Mautrix Telegram Bridge";
    dir = "mautrix-telegram";
    proxy = true;
    after = [ "synapse.service" ];
    partOf = [ "synapse.service" ];
    requires = [ "synapse.service" ];
    serviceConfig.ExecStart =
      let
        py = pkgs.python3.withPackages (p: with p; [ pysocks pkgs.mautrix-telegram ]);
      in
      "${py}/bin/python3 -m mautrix_telegram";
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

  systemd.services.synapse = make-service {
    description = "Synapse Matrix Home Server";
    dir = "synapse";
    proxy = true;
    after = [ "network.target" ];
    serviceConfig = {
      MemoryDenyWriteExecute = false;
      ExecStart =
        let oldpkgs = builtins.getFlake "github:NixOS/nixpkgs/8bb37161a0488b89830168b81c48aed11569cb93"; in
        "${oldpkgs.legacyPackages.${pkgs.system}.matrix-synapse}/bin/synapse_homeserver -c home_server.yaml";
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

  systemd.services.cloudflared = make-service {
    description = "Cloudflare Argo Tunnel";
    dir = "cloudflared";
    after = [ "network.target" ];
    serviceConfig.ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token ${import ./private/cloudflared-token.nix}";
  };

  systemd.services.caddy =
    let configFile = pkgs.writeText "caddy-config" ''
      :80
      file_server browse
      root * /srv/www
    '';
    in make-service {
      description = "Caddy HTTP Server";
      dynamic-user = false;
      dir = "caddy";
      after = [ "network.target" ];
      serviceConfig.ExecStart = "${pkgs.caddy}/bin/caddy run --adapter caddyfile --config ${configFile}";
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
    enable-instapaper = false;
  } // import ./private/instaepub.nix;
  systemd.services.instaepub = {
    serviceConfig = {
      User = "nicball";
      Group = "users";
    };
    environment = config.networking.proxy.envVars;
  };

  nic.cloudflare-ddns = {
    enable = true;
    enable-log = true;
    log-path = "/tmp/cloudflare-ddns.log";
  } // import ./private/cloudflare-ddns.nix;

  systemd.services.aria2d = make-service {
    description = "Aria2 Daemon";
    after = [ "network.target" ];
    dynamic-user = false;
    serviceConfig = {
      ProtectSystem = "full";
      User = "nicball";
      Group = "users";
      WorkingDirectory = "/srv/www/files";
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

  systemd.services.crawler = make-service {
    description = "Web Crawler";
    dir = "16k-crawler";
    proxy = true;
    wantedBy = [];
    serviceConfig = {
      Type = "oneshot";
      Restart = "no";
      ExecStart = "${pkgs.python3.withPackages (p: [ p.requests ])}/bin/python3 bot.py";
    };
  };

  systemd.timers.crawler = {
    description = "Timer for Web Crawler";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "hourly";
  };

  # systemd.services.nodebb = make-service {
  #   description = "NodeBB forum";
  #   dir = "nodebb";
  #   requires = [ "redis-nodebb.service" ];
  #   after = [ "redis-nodebb.service" ];
  #   serviceConfig = {
  #     Environment = "PATH=${pkgs.nodejs}/bin";
  #     ExecStart = "/var/lib/nodebb/nodebb start";
  #     ExecStop = "/var/lib/nodebb/nodebb stop";
  #     Type = "oneshot";
  #     Restart = "no";
  #     RemainAfterExit = true;
  #   };
  # };

  # services.redis.servers.nodebb = {
  #   enable = true;
  #   port = 6379;
  # };

  networking.firewall = {
    allowedTCPPorts = [ 80 6800 ];
    allowedUDPPortRanges = [ { from = 6881; to = 6999; } ];
    allowedTCPPortRanges = [ { from = 6881; to = 6999; } ];
  };

}
