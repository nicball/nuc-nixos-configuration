{ config, pkgs, ... }:

{
  services.factorio = {
    enable = true;
    admins = [ "nicball" ];
    description = "Nicball's Factorio Server";
    game-name = "MidyMidyFactorio";
    game-password = builtins.readFile ./private/factorio-password;
    saveName = "default";
    lan = true;
    openFirewall = true;
    # extraSettings = { auto_pause = false; };
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
  };
}
