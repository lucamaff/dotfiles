# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #./nextcloud.nix
    ];

  powerManagement.powertop.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 100;

  networking.hostName = "hp800g3"; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enables wireless support via wpa_supplicant.
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    networks = {
      alpha = {
        pskRaw = "ee94481d94ce6e66632ce161ae07079e97679a21bb5ecb8ed0b1f8bd4cc1f586";
      };
    };
  };

  networking.interfaces.wlp1s0.ipv4.addresses = [ {
    address = "192.168.178.101";
    prefixLength = 24;
  } ];
  networking.defaultGateway = "192.168.178.1";
  networking.nameservers = [ "192.168.178.1" ];

  # Disable networking, I use only wifi statically defined
  networking.networkmanager.enable = false;
  networking.networkmanager.unmanaged = [
    "*" "except:type:wwan" "except:type:gsm"
  ];

  networking.interfaces.eno1.ipv4.addresses = [{
    address = "192.168.1.11";
    prefixLength = 24;
  }];

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
    extraGroups = [ "networkmanager" "wheel" "nextcloud" "podman" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  #virtualisation = {
    #podman = {
      #enable = true;
      ## Create a `docker` alias for podman, to use it as a drop-in replacement
      #dockerCompat = true;
      ## Required for containers under podman-compose to be able to talk to each other.
      #defaultNetwork.settings.dns_enabled = true; # release 23.05
    #};
    #oci-containers.backend = "podman";
  #};

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
    iperf3
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    megacmd
    mergerfs
    mergerfs-tools
    ncdu
    parted
    smartmontools
    tmux
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wavemon
    wget
    xfsprogs
    yt-dlp
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

  services.plex = {
    enable = true;
    openFirewall = true;
  };

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
        "Chromebook" = {id = "CKVNSWH-FOJGT4C-YGNFNN3-OEIJ2BU-MWVIY37-TVR6HBI-NKQKWTL-SNLXDAO"; autoAcceptFolders = true; };
        "moto-g32" = { id = "J43GXHC-7SG4NRM-3OZ5Y3W-QTYBJGS-O6SQX2I-T2U42CR-W4DGE4Q-VKI2XAH"; autoAcceptFolders = true; };
        "nixos-gaming" = { id = "JXZZBVC-4CWRPBW-XOA52RJ-OHHANXK-XIHPRY5-SHTGQUH-UKFQM4M-EZGK3AT"; autoAcceptFolders = true; };
        "nixos-macmini" = { id = "NCANLZ5-ZM3WPT5-PE6X36O-YQLOPCR-AUHSJZX-3B74G72-V5F6KLM-XGJ2KQ5"; autoAcceptFolders = true; };
        "qnap-ts212" = { id = "6IHVZJZ-6KHTCME-2YYBMQ7-MN4JB4K-OBURXKK-HFI3I24-QWAEFKT-QSO4ZAR"; autoAcceptFolders = true; };
        "zimaboard" = { id = "NXOCWQY-TLCJGYA-UMQRFQM-ZD2LS5X-5RQY4TH-4DXZZC4-KKOWX32-IHPMRQL"; autoAcceptFolders = true; };
      };
      folders = {
        "BigLens" = {
          id = "62prt-kdyws";
          path = "/mnt/data/history/BigLens";
          devices = [ "nixos-gaming" "nixos-macmini" "zimaboard" ];
        };
        "EncFS" = {
          id = "j6e46-4z2f7";
          path = "/mnt/data/media/EncFS";
          devices = [ "nixos-gaming" "nixos-macmini" "zimaboard" ];
        };
        "MobileLaura" = {
          id = "moto_g_pro_8rrx-photos";
          path = "/mnt/data/history/MobileLaura";
          devices = [ "nixos-macmini"  "zimaboard"];
        };
        "MobileLuca" = {
          id = "moto_g32_v6vm-photos";
          path = "/mnt/data/history/MobileLuca";
          devices = [ "moto-g32" "nixos-gaming" "nixos-macmini" "zimaboard" ];
        };
        "Music" = {
          id = "an4zy-wuavw";
          path = "/mnt/data/media/Music";
          devices = [ "nixos-gaming" "nixos-macmini" "zimaboard" ];
        };
        "WhatsAppLaura" = {
          id = "5i2yp-05gou";
          path = "/mnt/data/history/WhatsAppLaura";
          devices = [ "nixos-macmini" "zimaboard" ];
        };
        "WhatsAppLuca" = {
          id = "tysor-1yp0m";
          path = "/mnt/data/history/WhatsAppLuca";
          devices = [ "moto-g32" "nixos-gaming" "nixos-macmini" "zimaboard" ];
        };
        "due" = {
          id = "7bjjp-3xtez";
          path = "/mnt/data/history/due";
          devices = [ "Chromebook" "moto-g32" "nixos-gaming""nixos-macmini" "zimaboard" ];
        };
        "CameraPapi" = {
          id = "moto_g8_power_zqnh-photos";
          path = "/mnt/data/history/CameraPapi";
          #devices = [ "nixos-gaming" "moto-g32" ];
          devices = [ "qnap-ts212" ];
        };
        "WhatsAppPapi" = {
          id = "sd1sl-9kgiw";
          path = "/mnt/data/history/WhatsAppPapi";
          #devices = [ "nixos-gaming" "moto-g32" ];
          devices = [ "qnap-ts212" ];
        };
      };    
    };    
  };

  services.tailscale.enable = true;

  services.transmission = {
    enable = true;
    user = "luca";
    openFirewall = true;
    openRPCPort = true;
    settings = {
      rpc-bind-address = "0.0.0.0"; #Bind to own IP
      rpc-whitelist = "127.0.0.1 192.168.*.*";  # Whitelist all machines in this network
      rpc-host-whitelist = "hp800g3.fritz.box";
      incomplete-dir-enabled = false;
      incomplete-dir = "/mnt/data/media/download/.incomplete";
      download-dir = "/mnt/data/media/download";
      encryption = 2;
      speed-limit-up-enabled = true;
      speed-limit-up = 1250;
      alt-speed-time-enabled = true;                 
      alt-speed-time-begin = 480;                                        
      alt-speed-time-end = 1320;
      alt-speed-up = 125;
      alt-speed-down = 125;
    };
  };

  #services.deluge = {
    #enable = true;
    #web.enable = true;
    #openFirewall = true;
    ##declarative = true;
    #config = {
      #download_location = "/mnt/data/media/deluge/download";
    #};
  #};
  #users.groups.deluge.members = [ "luca" ];

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
        #"create mask" = "0644";
        #"directory mask" = "0755";
        #"force user" = "luca";
        #"force group" = "luca";
      };
    };
  };

  # Browsing samba shares with GVFS
  services.gvfs.enable = true;
     
  # Jellyfin with hardware acceleration
  # 1. enable vaapi on OS-level
  #nixpkgs.config.packageOverrides = pkgs: {
    #vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  #};
  #hardware.opengl = {
    #enable = true;
    #extraPackages = with pkgs; [
      #intel-media-driver
      #vaapiIntel
      #vaapiVdpau
      #libvdpau-va-gl
      #intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
    #];
  #};

  # 2. do not forget to enable jellyfin
  #services.jellyfin = {
    #enable = true;
    #user = "luca";
  #};

  # Navidrome
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

  # Create folder for immich, where immich user can read/write
  systemd.tmpfiles.rules = [
    "d /mnt/data/immich 0771 luca immich -"
    #"d /mnt/data/media/deluge 0771 deluge deluge -"
  ];
  services.immich = {
    enable = true;
    mediaLocation = "/mnt/data/immich";
    host = "hp800g3.tail035a.ts.net";
    settings.server.externalDomain = "https://hp800g3.tail035a.ts.net";
  };  

  services.mealie = {
    enable = true;
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
    };
  };

  # Snapraid
  services.snapraid = {
    enable = true;
    dataDisks = {
      d1 = "/mnt/disk1";
      #d2 = "/mnt/disk2";
    };
    exclude = [
      "/lost+found/"
      "appdata/"
    ];
    parityFiles = [
      "/mnt/diskp/snapraid.parity"
    ];
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/disk1/snapraid.content"
      #"/mnt/disk2/snapraid.content"
    ];
    sync.interval = "06:10";
    scrub.interval = "Mon *-*-* 07:00:00";
  };

  # MergerFS to have multiple disk in a single path
  fileSystems."/mnt/data" = {
    #device = "/mnt/disk1:/mnt/disk2"; # multiple disks --> device = "/mnt/data1:/mnt/data2";
    device = "/mnt/disk1"; # multiple disks --> device = "/mnt/data1:/mnt/data2";
    fsType = "fuse.mergerfs";
    options = [
        "cache.files=partial"
        "dropcacheonclose=true"
        "category.create=mfs"
      ];
  };

  #systemd.services.hd-idle = {
  #description = "External HD spin down daemon";
  #wantedBy = [ "multi-user.target" ];
  #serviceConfig = {
    #Type = "forking";
    #ExecStart = "${pkgs.hd-idle}/bin/hd-idle";
  #};
  #};

  # auto standby
  services.cron.systemCronJobs = [
      "00 00 * * * root rtcwake -m disk --date +6h"
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
