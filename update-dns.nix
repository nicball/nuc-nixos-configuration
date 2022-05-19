{ config, pkgs, ... }:

{
  networking.dhcpcd.runHook =
    let
      updateScript = pkgs.writeShellApplication {
        name = "update-dns";
        runtimeInputs = with pkgs; [ curl jq ];
        text = ''
          authkey=${builtins.readFile ./private/cloudflare-auth-key}

          function cf() {
            local method=$1
            local function=$2
            local query=$3
            local extra_args=("''${@:4}")
            curl -s -X "$method" "https://api.cloudflare.com/client/v4/$function?$query" -H "X-Auth-Email: znhihgiasy@gmail.com" -H "X-Auth-Key: "$authkey -H "Content-Type: application/json" "''${extra_args[@]}"
          }

          my_ip=$(curl --noproxy '*' -s -6 ifconfig.co)
          zone_json=$(cf GET zones "name=nicball.me")
          zone_id=$(echo "$zone_json" | jq -r ".result[0].id")
          record_json=$(cf GET "zones/$zone_id/dns_records" "name=www.nicball.me")
          record_id=$(echo "$record_json" | jq -r ".result[0].id")
          results=$(cf PATCH "zones/$zone_id/dns_records/$record_id" "" --data "{\"content\":\"$my_ip\"}")
          {
            date
            echo "zone=$zone_json"
            echo "record=$record_json"
            echo "my_ip=$my_ip"
            echo "results=$results"
            echo
          } >> /var/log/update-dns.log
        '';
      };
    in
    ''
      {
        date
        env
        echo
      } >> /var/log/dhcpcd-debug.log
      
      if [ "$reason" = ROUTERADVERT -a "$if_up" = true ]
      then
        ${updateScript}/bin/update-dns
      fi
    '';
}
