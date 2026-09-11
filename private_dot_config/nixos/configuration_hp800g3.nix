# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 100;

  networking.hostName = "hp800g3"; # Define your hostname.

  # 2TB Western Digital disk
  fileSystems."/mnt/wd2001b" = 
  {
    device = "/dev/disk/by-uuid/aac7a363-3532-4964-a8a7-602c6623092e"; 
    fsType = "btrfs"; 
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  }; 
  
  # 1TB Seagate data disk
  #fileSystems."/mnt/sg1001b" = 
  #{
    #device = "/dev/disk/by-uuid/4c0551bd-936d-4722-9e66-72108c640156"; 
    #fsType = "btrfs"; 
    #options = [
      #"users" # Allows any user to mount and unmount
      #"nofail" # Prevent system from failing if this drive doesn't mount
    #];
  #};

  # 2TB Seagate data disk
  fileSystems."/mnt/sg2001b" = 
  {
    device = "/dev/disk/by-uuid/5d233d8a-0387-4d42-a41b-78bd5cf0585d"; 
    fsType = "ext4"; 
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # 3TB Toshiba parity disk
  fileSystems."/mnt/to3001b" = 
  {
    device = "/dev/disk/by-uuid/c0e9b266-d3a1-4798-8eeb-af648373f1ca"; 
    fsType = "xfs"; 
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # 2TB Ediloca NVME data disk
  #fileSystems."/mnt/el2001b" = 
  #{
    #device = "/dev/disk/by-uuid/7c5e4b55-d3dd-4879-8b06-b755dfb10fea"; 
    #fsType = "btrfs"; 
    #options = [
      #"users" # Allows any user to mount and unmount
      #"nofail" # Prevent system from failing if this drive doesn't mount
    #];
  #};

  # Spin down disks (120 = 10 minutes)
  #powerManagement.powerUpCommands = ''
    #${pkgs.hdparm}/sbin/hdparm -S 120 /dev/disk/by-uuid/5d233d8a-0387-4d42-a41b-78bd5cf0585d
    #${pkgs.hdparm}/sbin/hdparm -S 120 /dev/disk/by-uuid/c0e9b266-d3a1-4798-8eeb-af648373f1ca
    #${pkgs.hdparm}/sbin/hdparm -S 120 /dev/disk/by-uuid/f49960b7-f5b2-4844-b8ea-244bfbe97aca
  #'';

  # Spin down disks (120 = 10 minutes)
  systemd.services.disk-sleep = {
    description = "Run at boot to set spin down disks timer (120 = 10 minutes)";
    path = [
      pkgs.hdparm
    ];
    # the action taken when the service runs
    script = "hdparm -S 120 /dev/disk/by-uuid/5d233d8a-0387-4d42-a41b-78bd5cf0585d; hdparm -S 120 /dev/disk/by-uuid/aac7a363-3532-4964-a8a7-602c6623092e; hdparm -S 120 /dev/disk/by-uuid/c0e9b266-d3a1-4798-8eeb-af648373f1ca";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    wantedBy = [ "multi-user.target" ];
  };
  
  # Snapraid
  services.snapraid = {
    enable = true;
    dataDisks = {
      d1 = "/mnt/wd2001b";
      d2 = "/mnt/sg2001b";
      #d4 = "/home/luca/tmp";
    };
    exclude = [
      "/lost+found/"
      "appdata/"
    ];
    parityFiles = [
      "/mnt/to3001b/snapraid.parity"
    ];
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/wd2001b/snapraid.content"
      "/mnt/sg2001b/snapraid.content"
      #"/mnt/sg1001b/snapraid.content"
      #"/mnt/el2001b/snapraid.content"
    ];
    # Default: scrub weekly 8% of the array older than 10 days.
    # This means that scrubbing once a week, every bit of data is checked at least one time every three months. 
    sync.interval = "01:00";
    scrub = {
      interval = "Mon *-*-* 02:00:00";
      plan = 8;
      olderThan = 10;
    };
  };

  # MergerFS to have multiple disk in a single path
  #fileSystems."/mnt/data" = {
    #device = "/mnt/sg1001b:/mnt/sg2001b"; # multiple disks --> device = "/mnt/data1:/mnt/data2";
    #fsType = "fuse.mergerfs";
    #options = [
      #"cache.files=off"        # Disable file caching (recommended for large files)
      #"dropcacheonclose=true"  # Drop caches when files are closed
      #"moveonenospc=true"      # Move files when source drive is full
      #"ignorepponrename=true"  # Don't relocate stuff to another disk if I rename things
      #"minfreespace=100G"      # Reserve 100GB free space per drive
      #"category.create=mfs"    # path preserving algorithm
    #];
  #};

  # MergerFS to have multiple disk in a single path
  fileSystems."/mnt/hdd" = {
    device = "/mnt/sg2001b:/mnt/wd2001b"; # multiple disks --> device = "/mnt/data1:/mnt/data2";
    fsType = "fuse.mergerfs";
    options = [
      "cache.files=off"        # Disable file caching (recommended for large files)
      "dropcacheonclose=true"  # Drop caches when files are closed
      "moveonenospc=true"      # Move files when source drive is full
      "ignorepponrename=true"  # Don't relocate stuff to another disk if I rename things
      "minfreespace=100G"      # Reserve 100GB free space per drive
      "category.create=mfs"    # path preserving algorithm
      #"fsname=mergerfs-slow"   # Custom filesystem name for identification
    ];
  };

  fileSystems."/mnt/data" = {
    #device = "/mnt/el2001b:/mnt/hdd"; # multiple disks --> device = "/mnt/data1:/mnt/data2";
    device = "/mnt/hdd"; # multiple disks --> device = "/mnt/data1:/mnt/data2";
    fsType = "fuse.mergerfs";
    options = [
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=lfs" # least free space
    ];
  };

  # Share folder on the network
  services.samba = {
    enable = true;
    openFirewall = true;

    # You will still need to set up the user accounts to begin with:
    # $ sudo smbpasswd -a yourusername

    settings = {
      global = {
        browseable = "yes";
        "smb encrypt" = "required";
      };

      homes = {
        browseable = "no";  # note: each home will be browseable; the "homes" share will not.
        "read only" = "no";
        "guest ok" = "no";
      };
      data = {
        path = "/mnt/data";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };
  # Browsing samba shares with GVFS
  services.gvfs.enable = true;

  # Use nmcli to setup wifi connection
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luca = {
    isNormalUser = true;
    description = "Luca";
    extraGroups = [ "networkmanager" "wheel" "nextcloud" "podman" "immich" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs = {
    config = {
      allowUnfree = true;
      #packageOverrides = pkgs: {
        #unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};
      #};
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bitwarden-cli
    borgbackup
    btop
    chezmoi
    cifs-utils
    gh
    git
    helix
    hdparm
    hd-idle
    htop
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    iperf3
    megacmd
    mergerfs
    mergerfs-tools
    ncdu
    smartmontools
    starship
    syncthing
    tmux
    wavemon
    wget
    xfsprogs
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.fish.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "luca";
    dataDir = "/home/luca/Documents";    # Default folder for new synced folders
    configDir = "/home/luca/Documents/.config/syncthing";   # Folder for Syncthing's settings and keys
    guiAddress = "0.0.0.0:8384";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "moto-g54-luca" = { id = "34SJ4HM-6WEUPL2-HA7OVOD-OKTDUNE-RUGYPFV-VQBM3QR-FYJFYIB-OEP3DQ7"; };
        "moto-g54-laura" = { id = "7VGWXKO-GI673QT-INRM4FT-PIHWMNN-O4MEIXF-VHTUW3U-CSU5Y2O-WN4MJA6"; };
        "nixos-gaming" = { id = "JXZZBVC-4CWRPBW-XOA52RJ-OHHANXK-XIHPRY5-SHTGQUH-UKFQM4M-EZGK3AT"; };
        "macmini" = { id = "NCANLZ5-ZM3WPT5-PE6X36O-YQLOPCR-AUHSJZX-3B74G72-V5F6KLM-XGJ2KQ5"; };
        "SL3" = { id = "PUIWOMG-SGTQQQU-IMYD4Y4-6QLJHUL-GDYZZ7F-D7B5RQV-M4NJ4KG-5SHFVA3"; };
        "PCMamiPapi" = { id = "E6ZAXTG-JD5UBHV-OS2AJ2R-2SUQ6DE-M6BQP4R-U7O6Z4L-U6DYZF7-2USXJAC"; };
        "MiniPC" = { id = "DN56SO2-2FPLFIM-EGDDGH2-EAXNVL7-4Z5WBRZ-WBXHFWG-5FRFSSR-VDQBOAK"; };
        "zimaboard" = { id = "NXOCWQY-TLCJGYA-UMQRFQM-ZD2LS5X-5RQY4TH-4DXZZC4-KKOWX32-IHPMRQL"; };
        "moto-g8 papi" = { id = "5ICHBLQ-EV4DVOK-ZQZUXUD-5Q776NO-QFGJAQV-HDL6VK6-VDFT4O3-73Z5BA2"; };
      };
      folders = {
        "BigLens" = {
          id = "62prt-kdyws";
          path = "/mnt/data/history/BigLens";
          devices = [ "nixos-gaming" "macmini" "zimaboard" "SL3" ];
        };
        "EncFS" = {
          id = "j6e46-4z2f7";
          path = "/mnt/data/media/EncFS";
          devices = [ "nixos-gaming" "macmini" "zimaboard" "SL3" ];
        };
        "MobileLaura" = {
          id = "moto_g_pro_8rrx-photos";
          path = "/mnt/data/history/MobileLaura";
          devices = [ "moto-g54-laura" "macmini" "zimaboard"];
        };
        "MobileLuca" = {
          id = "moto_g32_v6vm-photos";
          path = "/mnt/data/history/MobileLuca";
          devices = [ "nixos-gaming" "macmini" "zimaboard" "SL3" "moto-g54-luca" ];
        };
        "Music" = {
          id = "an4zy-wuavw";
          path = "/mnt/data/media/Music";
          devices = [ "nixos-gaming" "macmini" "zimaboard" "SL3" ];
        };
        "WhatsAppLaura" = {
          id = "5i2yp-05gou";
          path = "/mnt/data/history/WhatsAppLaura";
          devices = [ "moto-g54-laura" "macmini" "zimaboard" ];
        };
        "WhatsAppLuca" = {
          id = "tysor-1yp0m";
          path = "/mnt/data/history/WhatsAppLuca";
          devices = [ "nixos-gaming" "macmini" "zimaboard" "SL3" "moto-g54-luca" ];
        };
        "due" = {
          id = "7bjjp-3xtez";
          path = "/mnt/data/history/due";
          devices = [ "nixos-gaming" "macmini" "zimaboard" "moto-g54-luca" "SL3" ];
        };
        "BASB" = {
          id = "3owyw-oilad";
          path = "/mnt/data/history/BASB";
          devices = [ "nixos-gaming" "macmini" "zimaboard" "moto-g54-luca" "SL3" ];
        };
        "CameraPapi" = {
          id = "moto_g8_power_zqnh-photos";
          path = "/mnt/data/history/CameraPapi";
          devices = [ "PCMamiPapi" "MiniPC" "zimaboard" "moto-g8 papi" ];
        };
        "WhatsAppPapi" = {
          id = "sd1sl-9kgiw";
          path = "/mnt/data/history/WhatsAppPapi";
          devices = [ "PCMamiPapi" "MiniPC" "zimaboard" "moto-g8 papi" ];
        };
        "duplicatiRepoZIMABOARD" = {
          id = "cnyrk-f3qw9";
          path = "/mnt/hdd/backup/mamipapi/duplicati/remoterepo/zimaboard";
          devices = [ "zimaboard" ];
          type = "receiveonly";
        };
      };    
    };    
  };

  # Immich (replace Google Photo) 
  services.immich = {  
    enable = true;  
    #user = "luca";
    #group = "users";
    mediaLocation = "/mnt/data/media/immich"; 
    host = "0.0.0.0";  
    settings.server.externalDomain = "https://hp800g3";  
    openFirewall = true;  
  };

  services.postgresql = {
  enable = true;
  package = pkgs.postgresql_14.withPackages (ps: [
    ps.pgvector
    #ps.vectorchord  # Only add this if your dump specifically requires vectorchord
  ]);
};
  
  # Tailscale (VPN)
  services.tailscale.enable = true;
  services.tailscale.package = pkgs.tailscale.overrideAttrs { doCheck = false; };

  # Plex (Movies, TV shows)
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  # Jellyfin (Movies, TV shows)
  # runs on port 8096
  services.jellyfin = {
    enable = true;
    user = "luca";
  };

  # https://github.com/NixOS/nixpkgs/issues/481611
  #nixpkgs.overlays = [
    #(self: super: {
      #navidrome = self.callPackage (pkgs.fetchurl {
        #url = "https://raw.githubusercontent.com/cimm/nixpkgs/71aa374ad541b41e6fccd543c67b6952d2ccafca/pkgs/by-name/na/navidrome/package.nix";
        #sha256 = "16mfj85w8d7vzc9pgcgjn7a71z7jywqpdn8igk9zp0hw9dvm9rmq";
      #}) {};
    #})
  #];

  # Navidrome (Music)
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/mnt/data/media/Music/CD";
      Address = "0.0.0.0";
      ImageCacheSize = "1GB";
      LastFM.ApiKey = "0987c2ad94f73d2bba753d7ce9123a65";
      LastFM.Secret = "3debb1b9dd1f2a5a580266ab9859dfeb";
    };
  };

  # Transmission (torrent)
  services.transmission = {
    package = pkgs.transmission_4;
    enable = true;
    user = "luca";
    openFirewall = true;
    openRPCPort = true;
    settings = {
      rpc-bind-address = "0.0.0.0"; #Bind to own IP
      rpc-whitelist = "127.0.0.1 192.168.178.*";  # Whitelist all machines in this network
      rpc-host-whitelist = "hp800g3.fritz.box";
      incomplete-dir-enabled = true;
      incomplete-dir = "/mnt/data/media/torrent/incomplete";
      download-dir = "/mnt/data/media/torrent/download";
      preallocation = 2;
      encryption = 2;
      alt-speed-time-enabled = true;                 
      alt-speed-time-begin = 480;                                        
      alt-speed-time-end = 1380;
      alt-speed-up = 1000;
      alt-speed-down = 2000;
    };
  };

  services.qbittorrent = {
    enable = true;
    extraArgs = ["--confirm-legal-notice"];
    webuiPort = 8081;
  };

  # Home Assistant
  services.home-assistant = {         
    enable = true;                       
    extraComponents = [                                                                          
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
      "netatmo"  # Termostato
      "tuya"  # Smart plugs
      "xiaomi_miio"  # Xiaomi Mi Robot Vacuum
    ];                                           
    config = {                                                                                                
      # Includes dependencies for a basic setup 
      # https://www.home-assistant.io/integrations/default_config/ 
      default_config = {};
      homeassistant = {
        name = "Casa Azzio";
        latitude = 45.88624994171359;
        longitude = 8.710174693276345;
        elevation = 400;
        country = "IT";
        time_zone= "Europe/Rome";
        unit_system = "metric";
      };
      #vacuum = {
        #platform = "xiaomi_miio";
        #host = "192.168.178.31";
        #token = "4630727a7254524b57586934675a7a38";
      #};
    };                                                                
  };   

  # Optimising the store
  nix.settings.auto-optimise-store = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d";
  };

  powerManagement.powertop.enable = true;
  
  services.cron.systemCronJobs = [
      #"30 01 * * * root rtcwake -m disk --date +7h"  # auto standby
      "@reboot root sleep 20 && systemctl restart navidrome.service"  # quick hack to wait for all disks
      "@reboot root sleep 22 && systemctl restart syncthing.service"  # quick hack to wait for all disks
      "@reboot root sleep 24 && systemctl restart transmission.service"  # quick hack to wait for all disks
      "00 00 * * * luca /home/luca/tools/mergerfs/tools/mergerfs.percent-full-mover /mnt/el2001b /mnt/hdd 0"  # tiered cache mover
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
