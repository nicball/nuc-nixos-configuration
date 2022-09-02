{ config, pkgs, ... }:

{
  networking.useDHCP = true;
  networking.interfaces = {
    eno1 = {
      useDHCP = true;
      tempAddress = "disabled";
    };
    wlp2s0 = {
      useDHCP = false;
      ipv4.addresses = [ {
        address = "192.168.0.42";
        prefixLength = 24;
      } ];
    };
  };
  # networking.wireless = {
  #   enable = true;
  #   networks = {
  #     Cain = { pskRaw = "23bce2da261d5c51a04006afe42507d703afd0ca82fa2e0baf28d946b0b3ee4d"; };
  #     OnePlus = { psk = "w0sh1iio"; };
  #   };
  # };

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    internalInterfaces = [ "wlp2s0" ];
    internalIPs = [ "192.168.0.0/24" ];
    externalInterface = "eno1";
  };

  services.radvd = {
    enable = true;
    config = ''
      interface wlp2s0 {
        IgnoreIfMissing on;
        AdvSendAdvert on;
        prefix ::/64 {
          AdvOnLink on;
          AdvAutonomous on;
        };
      };
    '';
  };

  services.dhcpd4 = {
    enable = true;
    interfaces = [ "wlp2s0" "eno1" ]; # TODO
    extraConfig = ''
      option domain-name-servers 8.8.8.8, 208.67.222.222;
      subnet 192.168.42.0 netmask 255.255.255.0 {
        option routers 192.168.42.1;
        range 192.168.42.100 192.168.42.200;
      }
      subnet 192.168.0.0 netmask 255.255.255.0 {
        option routers 192.168.0.42;
        range 192.168.0.100 192.168.0.200;
      }
    '';
  };

  networking.dhcpcd = {
    enable = true;
    extraConfig = ''
      release
      duid
      noipv6rs
      waitip 6
      interface eno1
        ipv6rs
        iaid 1
        ia_pd 1/::/64 wlp2s0/0/64
    '';
    allowInterfaces = [ "eno1" "wlp2s0" ];
  };

  services.hostapd = {
    enable = true;
    interface = "wlp2s0";
    ssid = "Cain";
    wpaPassphrase = "zhangshiyisuxiaoshuang";
    countryCode = "CN";
    hwMode = "a";
    channel = 149;
    extraConfig = ''
      ieee80211n=1
      ieee80211ac=1
      wpa_pairwise=CCMP
      auth_algs=1
      wmm_enabled=1
      wpa_key_mgmt=WPA-PSK
      ht_capab=[HT40-][HT40+][GF][LDPC][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1]
      vht_capab=[MAX-MPDU-7991][RXLDPC][SHORT-GI-80][TX-STBC-2BY1][SU-BEAMFORMEE][MU-BEAMFORMEE][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]
    '';
  };
}
