#!/usr/bin/fish

set authkey (cat /etc/nixos/private/cloudflare-auth-key)

function cf
  set -l method $argv[1]
  set -l function $argv[2]
  set -l query $argv[3]
  set -l extra_args $argv[4..]
  curl -s -X $method "https://api.cloudflare.com/client/v4/$function?$query" -H "X-Auth-Email: znhihgiasy@gmail.com" -H "X-Auth-Key: "$authkey -H "Content-Type: application/json" $extra_args
end

set my_ip (curl --noproxy '*' -s -6 ifconfig.co)
set zone_json (cf GET zones "name=nicball.me")
set zone_id (echo $zone_json | jq -r ".result[0].id")
set record_json (cf GET "zones/$zone_id/dns_records" "name=www.nicball.me")
set record_id (echo $record_json | jq -r ".result[0].id")
set results (cf PATCH "zones/$zone_id/dns_records/$record_id" "" --data '{ "content": "'$my_ip'" }')
begin
  date
  echo "zone=$zone_json"
  echo "record=$record_json"
  echo "my_ip=$my_ip"
  echo "results=$results"
  echo
end >> /var/log/update-dns.log
