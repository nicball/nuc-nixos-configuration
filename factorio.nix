{ config, pkgs, ... }:

{
  services.factorio = {
    enable = true;
    admins = [ "nicball" ];
    description = "Nicball's Factorio Server";
    game-name = "MidyMidyFactorio";
    game-password = pkgs.lib.removeSuffix "\n" (builtins.readFile ./private/factorio-password);
    saveName = "server";
    lan = true;
    openFirewall = true;
    autosave-interval = 60;
    requireUserVerification = false;
    extraSettings = { auto_pause = false; };
    mods =
      let
        inherit (pkgs) lib;
        modDir = ./factorio-mods;
        modList = lib.pipe modDir [
          builtins.readDir
          (lib.filterAttrs (k: v: v == "regular"))
          (lib.mapAttrsToList (k: v: k))
          (builtins.filter (lib.hasSuffix ".zip"))
        ];
        modToDrv = modFileName:
          pkgs.runCommand "copy-factorio-mods" {} ''
            mkdir $out
            cp ${modDir + "/${modFileName}"} $out/${modFileName}
          ''
          // { deps = []; };
      in
        builtins.map modToDrv modList;
    package = pkgs.factorio-headless.overrideAttrs (self: super: {
      installPhase = super.installPhase + ''
        wrapProgram $out/bin/factorio --add-flags "--rcon-bind localhost:9790 --rcon-password 233"
      '';
      nativeBuildInputs = (super.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    });
  };

  systemd.services.factorio-bot = {
    description = "Factorio Telegram Bridge";
    wantedBy = [ "factorio.service" ];
    after = [ "factorio.service" ];
    partOf = [ "factorio.service" ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.jre}/bin/java -Dhttp.proxyHost=localhost -Dhttp.proxyPort=7890 -Dhttps.proxyHost=localhost -Dhttps.proxyPort=7890 -jar " + ./private/factorio-bot.jar;
    };
  };
}
