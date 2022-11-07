# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, emacs-overlay, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # try gnome
  # services.xserver = {
  #   enable = true;
  #   desktopManager.gnome.enable = true;
  #   displayManager.gdm.enable = true;
  # };

  # GPU passthrough
  # boot.kernelPackages = pkgs.linuxPackages_5_10;
  # boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
  # boot.initrd.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
  # boot.initrd.kernelModules = [ "vfio_iommu_type1" "kvmgt" "mdev" ];
  # boot.blacklistedKernelModules = [ "nvidia" "nouveau" ];
  # boot.extraModprobeConfig = ''
  #   options vfio-pci ids=10de:1c8c,10de:0fb9
  #   options kvm ignore_msrs=1
  #   options kvm_intel nested=1
  #   options kvm_intel emulate_invalid_guest_state=0
  # '';
  # boot.extraModprobeConfig = "options i915 enable_gvt=1";
  # services.udev.extraRules = ''SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"'';
  # security.pam.loginLimits = [
  #   {
  #     domain = "@kvm";
  #     type = "soft";
  #     item = "memlock";
  #     value = "unlimited";
  #   }
  #   {
  #     domain = "@kvm";
  #     type = "hard";
  #     item = "memlock";
  #     value = "unlimited";
  #   }
  # ];
  # virtualisation.libvirtd.enable = true;

  # NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Do nothing when closing the lid with wall power
  services.logind.lidSwitchExternalPower = "ignore";

  # Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages =
      with pkgs;
      let screenshot = writeShellScriptBin "screenshot" ''
        file=$(mktemp /tmp/XXXXXXXXXXX-screenshot.png)
        grim $file
        read w h x y < <(slurp -f "%w %h %x %y")
        convert $file -crop $((w*3/2))x$((h*3/2))+$((x*3/2))+$((y*3/2)) /tmp/latest-screenshot.png
        wl-copy --type image/png < /tmp/latest-screenshot.png
        rm $file
      ''; in
      [ screenshot dmenu waybar grim slurp wl-clipboard mako gnome.adwaita-icon-theme imagemagick ];
    extraOptions = [ "--unsupported-gpu" ];
  };
  xdg = {
    portal.wlr.enable = true;
  };

  # Input methods
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-rime ];
  };

  # Fonts
  fonts.fonts = with pkgs; [
    source-han-sans source-han-serif
    source-code-pro
    font-awesome_5
    mononoki
    julia-mono
  ];

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };
  hardware.bluetooth = {
    enable = true;
  };

  # Steam
  programs.steam.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # For keyboard patch
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_0;

  # For realtek wifi
  boot.extraModulePackages = [ (builtins.getFlake "github:nicball/nicpkgs/f6653bf2f270517bf26efe43a39c13b5cc226918").packages.x86_64-linux.rtw89 ];
  hardware.firmware = [ (builtins.getFlake "github:nicball/nicpkgs/f6653bf2f270517bf26efe43a39c13b5cc226918").packages.x86_64-linux.rtw89-firmware ];

  # For amd turbo boost
  # boot.kernelParams = [
  #   "initcall_blacklist=acpi_cpufreq_init"
  #   "amd_pstate.shared_mem=1"
  # ];
  # boot.kernelModules = [ "amd-pstate" ];
  # powerManagement.cpuFreqGovernor = "performance";
  
  # Time zone
  time.timeZone = "Asia/Shanghai";
  # Compatible with Windows
  time.hardwareClockInLocalTime = true;

  # hardware.opengl = {
  #   enable = true;
  #   extraPackages = [ pkgs.intel-media-driver ];
  # };

  # Clash
  systemd.services.clash = {
    description = "Clash Daemon";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.clash}/bin/clash -f ${./clash-config.yaml} -d /var/clash";
    };
  };

  # Network
  networking = {
    hostName = "nicball-nixos";

    proxy.httpProxy = "http://127.0.0.1:7890";
    proxy.httpsProxy = "http://127.0.0.1:7890";
    proxy.noProxy = "127.0.0.1,localhost";

    useDHCP = false;
    interfaces.enp2s0.useDHCP = true;
    interfaces.wlo1.useDHCP = true;

    # Disable IPV6 temp address
    tempAddresses = "disabled";

    # DNS
    nameservers = [ "8.8.8.8" "8.8.4.4" "2001:4860:4860::8888" "2001:4860:4860::8888" ];
    hosts = {
        "202.38.64.59" = [ "wlt.ustc.edu.cn" "wlt" ];
    };
    dhcpcd.extraConfig = ''
        nohook resolv.conf
        release
    '';

    # Wireless
    wireless.enable = true;
    wireless.networks = import ./wireless-networks.nix;
    wireless.userControlled.enable = true; # allow wpa_cli to connect
  };

  # services.zerotierone = {
  #   enable = true;
  #   joinNetworks = [ "8286ac0e47b1e8e6" ];
  # };
  # services.samba = {
  #   enable = true;
  #   openFirewall = true;
  #   shares = { aria2d = {
  #     path = "/var/aria2d";
  #     writable = "yes";
  #   }; };
  # };

  # Nix channels
  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" "https://cache.nixos.org/" ];
  nixpkgs.config.allowUnfree = true;

  # Users
  users.users.nicball = {
    isNormalUser = true;
    createHome = false;
    home = "/home/nicball";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    hashedPassword = "$6$2ftGKK8s43tQPi3E$joCjNfgJQjUH8Lq3MUVOTyHXrh4ANPvmdh7m/jCzCQR6ogpzteRIoY.pIHpC0pGlNd5biJAQOge2iZ7oBit.u/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDD/sYNnlvX6Hfrwb8y90+yHRg5JODsi7JSkM/IOuJIumxNGISqtQuEJWwQoV5csLNPOILtLS/8EiS/EhkPXWNkJddE/6BC0/cQkUtVrC3x7Y2tfY3Fr0XdlqHwh+AwX13mFbzTbU9N9qTXZ5rZwuh1+4IS24Ite/d5S9CIHvOWi3yEOYFU+BOdItO9Dxou8C4PPZ/lx+Tc2l7aq+/ZW9cEIwh4GkH7ewFbFGrrNlrKrZae4Tfiyln1n/AN4o8tKQTsJOci/KPlmrU74NrWuMQVay6Tt9tI4XvSQFDnuToDwqet15oGYC11gd9ggMFT5QuEtuC8bob8pe9I84pkwowpGmlxQ95OdjVI82mJNYULTAWwRIZ6OUKPEAsMEnHYqL1pYM/HeSKUOdlGAUsZKgfx6kuY/altbCM1d4sBWeP35o7pd/UZHO2MSzjUn0ZGjRf8qmcIOzx8OIJqBpFFD5wTmK61AfClDduKjoebCab6q2yGL9QJmNvuMuB4IeYi1oE= sahib@sahib-laptop"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsJCAQa0SniQbEtPifaAQxoq3N68DnbSWzmSNj8h16D3RXW1054QUYleoSJcmS4P9tiXv1FxcE3hJkjByqnxX81bdSazpXNtN3186V/EpKXXcEXb+eERVZ7xkcaM2VS0CkytOXGxHtCCCypbVvJBKgbiSiqF3/94ItXz3PHp3m/iKVhibFl41tWp5cvB0bWfxtePtk4j60TpmwJU2ReSN01F7lVxHuxH4lqoFlOAXS5pxXuEOkBh1E/KIS8ycI4yYsSw+NpfMGJi2kwCtS+F5vmRSJvSZcfOy8WkEyT34GmrPAKLj+K3vleFHfdbEQIp/G8TR1/D9gmc5qANPCIb1MCnQdDMaP53vc7sn3CzjyCW7xXDNgdyfKqQjVBc1TDu47lEi/m+dcQ6z15aRQR5Zq/MOTd+GgYo1OgIdDZJbiNAtyzC5T0cZ9o1cbnPEQ6gSeKYXnp/7+3M+1qcgalVKj9Rt0uk/1sIdX/dPk/GkvOK/VX8lXJXuk570KWosgzIE= sahib@sahib-laptop"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCQLT7PlxmtUtHpJaDIcrAZGwL7Alah861wUY9WJGNMMhT+A+GxyLFCb7K0kN4n59C6K0flMuGYjYkGw/rbf9uYLrLDhaY9PR51UcOOeMNmy7+miadBaHTgssIRFV0TIscQF5mNIzIit+m5gWNPq2cNlSe41ziCnUU7S3MpYB0J/2M5/EVz71PS7dmvgCKF9bR16Q+C2tNArho8UGgBnET9v8w/cLzzp2SRedXcvN7O3Ya2rQkcwMOTGHAE9+9ozmfIqzUBS2XJj4NaCTTBJta+6EEj89OK11bAZjmf+WrbJ28on066GyA//YdBJtwE+0ndc+taxg7mtXynS+c15EbN oneplus"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKxLJ4lOEgEjbRKPBTypjOybPFOouuV0R+cHrmSCKR0WNBMN3HF7Pz3ApyDOJIQSb5q+xH2/GcP9VS2cxiU/UUzHJ4eqnu8Dw66+ERFuepjU/yPg1CuOHmKEZf1g7s+24AxlMSCYMEhRPy1zbwEynIk46/x/k/8V2sso/u9kTqymDjd4RLWieJfgtZ31kD/iLpTWP+WXDcuW4G67/T9VN8xdaJ8L6guefWQi9wcNWabJ4zWM1kBXq92CMEOU45wBNVU+EZFQ5J30LKhgh44w6f7M3xhUk8ifJ924caZu825gmyayFtKEfkcSpcr2AlCr/FHjPJVNuCVfd4Q6ENY5lV55/cwMx9ufm6OoCL6BoQnDHr71Djo/ee7/WNxx8wF6wOl0M1M1rV5bnq4wZrw+8OvyGejEN/kScpjySSVNB2z+hi1o93aSZ2ocb1ztUGKoCxfFf6xoQpO1sXjSL+Vbilae7joYVvm8sJRtX61LuQ1ylYCxWcki1KhvgTPEFslhc= nicball@nicball-nixos-laptop"
    ];
  };
  users.users.wine = {
      isNormalUser = true;
      home = "/home/wine";
      shell = pkgs.fish;
      hashedPassword = "$6$2ftGKK8s43tQPi3E$joCjNfgJQjUH8Lq3MUVOTyHXrh4ANPvmdh7m/jCzCQR6ogpzteRIoY.pIHpC0pGlNd5biJAQOge2iZ7oBit.u/";
  };

  security.sudo.wheelNeedsPassword = false;

  # Fish shell
  programs.fish.enable = true;

  # Emacs
  nixpkgs.overlays = [ (import emacs-overlay) ];

  # Apps
  environment.systemPackages =
    with pkgs;
    [
      # dev
      vim git nodejs kakoune gcc jre gradle
      ((emacsPackagesFor emacsPgtkNativeComp).emacsWithPackages (epkgs: [epkgs.vterm])) ripgrep # direnv nix-direnv
      (pkgs.agda.withPackages (p: [ p.standard-library ]))

      # i3
      # polybarFull xclip maim dmenu

      # apps
      kitty google-chrome mate.caja vlc pavucontrol
      obs-studio clash tigervnc
      calibre tdesktop

      # cli tools
      file acpilight wget htop zip unzip neofetch jq screen
      cpufrequtils intel-gpu-tools parted lm_sensors
      sysstat usbutils pciutils pv rsync
      dhcp iperf lsof iw wirelesstools traceroute aria2

      # games
      # openttd minecraft fabric-installer mc
    ];

  # Default Applications
  environment.variables = {
      EDITOR = "kak";
      BROWSER = "google-chrome-stable";
  };

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = { registry-mirrors = [ "https://docker.mirrors.ustc.edu.cn/" ]; };

  # Nix flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.package = pkgs.nixUnstable;

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh = {
  #   enable = true;
  #   # permitRootLogin = "yes";
  #   forwardX11 = true;
  #   passwordAuthentication = false;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [
  #   25565 8123 # mc
  #   # 1935 # owncast
  #   9090 # clash
  #   # 3001 3005 # shapez
  #   2344 2345 # arma3
  #   # 7500 # frps dashboard
  #   5900 # vnc
  #   10308 # dcs
  #   8088 # dcs web
  #   # 5201 # iperf
  #   # 7890 7891 # clash
  # ];
  # networking.firewall.allowedUDPPorts = [
  #   2302 2303 2304 2305 2306 2344 # arma3
  #   # 27015 27016 # barotrauma
  #   10308 # dcs
  #   # 7890 7891 # clash
  # ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
