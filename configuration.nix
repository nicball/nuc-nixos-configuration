# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./networks.nix
      ./aria2d.nix
      ./update-dns.nix
      ./lighttpd.nix
      ./wireguard.nix
      # ./tailscale.nix
      ./factorio.nix
      # ./postgresql.nix
      # ./matrix.nix
      # ./redis.nix
    ];

  # services.xserver = {
  #   enable = true;
  #   videoDrivers = [ "amdgpu" ];
  #   autorun = false;
  #   # displayManager.xpra.enable = true;
  # };

  programs.sway.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  programs.steam.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # For wifi driver
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # For amd turbo boost
  boot.kernelParams = [
    "initcall_blacklist=acpi_cpufreq_init"
    "amd_pstate.shared_mem=1"
  ];
  boot.kernelModules = [ "amd-pstate" ];
  powerManagement.cpuFreqGovernor = "performance";
  
  time.timeZone = "Asia/Shanghai";

  # hardware.opengl = {
  #   enable = true;
  #   extraPackages = [ pkgs.intel-media-driver ];
  # };

  networking.hostName = "nicball-nixos-um560";
  networking.proxy.httpProxy = "http://127.0.0.1:7890";
  networking.proxy.httpsProxy = "http://127.0.0.1:7890";
  networking.proxy.noProxy = "127.0.0.1,localhost";
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "8286ac0e47b1e8e6" ];
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    shares = { aria2d = {
      path = "/var/aria2d";
      writable = "yes";
    }; };
  };

  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" "https://cache.nixos.org/" ];

  users.users.nicball = {
    isNormalUser = true;
    createHome = false;
    home = "/home/nicball";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" "aria2d" ];
    hashedPassword = "$6$2ftGKK8s43tQPi3E$joCjNfgJQjUH8Lq3MUVOTyHXrh4ANPvmdh7m/jCzCQR6ogpzteRIoY.pIHpC0pGlNd5biJAQOge2iZ7oBit.u/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDD/sYNnlvX6Hfrwb8y90+yHRg5JODsi7JSkM/IOuJIumxNGISqtQuEJWwQoV5csLNPOILtLS/8EiS/EhkPXWNkJddE/6BC0/cQkUtVrC3x7Y2tfY3Fr0XdlqHwh+AwX13mFbzTbU9N9qTXZ5rZwuh1+4IS24Ite/d5S9CIHvOWi3yEOYFU+BOdItO9Dxou8C4PPZ/lx+Tc2l7aq+/ZW9cEIwh4GkH7ewFbFGrrNlrKrZae4Tfiyln1n/AN4o8tKQTsJOci/KPlmrU74NrWuMQVay6Tt9tI4XvSQFDnuToDwqet15oGYC11gd9ggMFT5QuEtuC8bob8pe9I84pkwowpGmlxQ95OdjVI82mJNYULTAWwRIZ6OUKPEAsMEnHYqL1pYM/HeSKUOdlGAUsZKgfx6kuY/altbCM1d4sBWeP35o7pd/UZHO2MSzjUn0ZGjRf8qmcIOzx8OIJqBpFFD5wTmK61AfClDduKjoebCab6q2yGL9QJmNvuMuB4IeYi1oE= sahib@sahib-laptop"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsJCAQa0SniQbEtPifaAQxoq3N68DnbSWzmSNj8h16D3RXW1054QUYleoSJcmS4P9tiXv1FxcE3hJkjByqnxX81bdSazpXNtN3186V/EpKXXcEXb+eERVZ7xkcaM2VS0CkytOXGxHtCCCypbVvJBKgbiSiqF3/94ItXz3PHp3m/iKVhibFl41tWp5cvB0bWfxtePtk4j60TpmwJU2ReSN01F7lVxHuxH4lqoFlOAXS5pxXuEOkBh1E/KIS8ycI4yYsSw+NpfMGJi2kwCtS+F5vmRSJvSZcfOy8WkEyT34GmrPAKLj+K3vleFHfdbEQIp/G8TR1/D9gmc5qANPCIb1MCnQdDMaP53vc7sn3CzjyCW7xXDNgdyfKqQjVBc1TDu47lEi/m+dcQ6z15aRQR5Zq/MOTd+GgYo1OgIdDZJbiNAtyzC5T0cZ9o1cbnPEQ6gSeKYXnp/7+3M+1qcgalVKj9Rt0uk/1sIdX/dPk/GkvOK/VX8lXJXuk570KWosgzIE= sahib@sahib-laptop"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCQLT7PlxmtUtHpJaDIcrAZGwL7Alah861wUY9WJGNMMhT+A+GxyLFCb7K0kN4n59C6K0flMuGYjYkGw/rbf9uYLrLDhaY9PR51UcOOeMNmy7+miadBaHTgssIRFV0TIscQF5mNIzIit+m5gWNPq2cNlSe41ziCnUU7S3MpYB0J/2M5/EVz71PS7dmvgCKF9bR16Q+C2tNArho8UGgBnET9v8w/cLzzp2SRedXcvN7O3Ya2rQkcwMOTGHAE9+9ozmfIqzUBS2XJj4NaCTTBJta+6EEj89OK11bAZjmf+WrbJ28on066GyA//YdBJtwE+0ndc+taxg7mtXynS+c15EbN oneplus"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKxLJ4lOEgEjbRKPBTypjOybPFOouuV0R+cHrmSCKR0WNBMN3HF7Pz3ApyDOJIQSb5q+xH2/GcP9VS2cxiU/UUzHJ4eqnu8Dw66+ERFuepjU/yPg1CuOHmKEZf1g7s+24AxlMSCYMEhRPy1zbwEynIk46/x/k/8V2sso/u9kTqymDjd4RLWieJfgtZ31kD/iLpTWP+WXDcuW4G67/T9VN8xdaJ8L6guefWQi9wcNWabJ4zWM1kBXq92CMEOU45wBNVU+EZFQ5J30LKhgh44w6f7M3xhUk8ifJ924caZu825gmyayFtKEfkcSpcr2AlCr/FHjPJVNuCVfd4Q6ENY5lV55/cwMx9ufm6OoCL6BoQnDHr71Djo/ee7/WNxx8wF6wOl0M1M1rV5bnq4wZrw+8OvyGejEN/kScpjySSVNB2z+hi1o93aSZ2ocb1ztUGKoCxfFf6xoQpO1sXjSL+Vbilae7joYVvm8sJRtX61LuQ1ylYCxWcki1KhvgTPEFslhc= nicball@nicball-nixos-laptop"
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  programs.fish.enable = true;
  environment.systemPackages =
    with pkgs;
    [
      # dev
      vim git clash
      # cli tools
      file wget htop screen
      # sys
      lm_sensors sysstat cpufrequtils
      # games
      papermc openttd terraria-server steamcmd jre
    ];
  virtualisation.docker.enable = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.package = pkgs.nixUnstable;

  nixpkgs.config.allowUnfree = true;

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # permitRootLogin = "yes";
    forwardX11 = true;
    passwordAuthentication = false;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    25565 8123 # mc
    # 1935 # owncast
    9090 # clash
    # 3001 3005 # shapez
    2344 2345 # arma3
    # 7500 # frps dashboard
    5900 # vnc
    10308 # dcs
    8088 # dcs web
  ];
  networking.firewall.allowedUDPPorts = [
    2302 2303 2304 2305 2306 2344 # arma3
    # 27015 27016 # barotrauma
    10308 # dcs
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

