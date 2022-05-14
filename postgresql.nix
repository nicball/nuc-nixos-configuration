{ config, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql;
    authentication = "local all all trust";
    initialScript = pkgs.writeText "postgre-initScript" ''
      CREATE ROLE postgres WITH LOGIN PASSWORD 'postgres' CREATEDB;
      CREATE DATABASE postgres;
      GRANT ALL PRIVILEGES ON DATABASE postgres TO postgres;
    '';
  };
}
