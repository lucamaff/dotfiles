# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      #/home/luca/docker/urbackup/docker-compose.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.59"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "macmini"; # Define your hostname.
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
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # 2 TB Faxiang 2.5 SSD
  #fileSystems."/mnt/fx2001b" = {
    #device = "/dev/disk/by-uuid/b7343d31-d87d-4bf4-816b-128f6c6f15ee";
    #fsType = "ext4";
    #options = [
      #"users" # Allows any user to mount and unmount
      #"nofail" # Prevent system from failing if this drive doesn't mount
    #];
  #};

  # 5 TB WD external USB disk
  #fileSystems."/mnt/wd5001b" = {
    #device = "/dev/disk/by-uuid/c3adb1ac-c332-4c71-bb2a-8cf0a182fbb4";
    #fsType = "ext4";
    #options = [
      #"users" # Allows any user to mount and unmount
      #"nofail" # Prevent system from failing if this drive doesn't mount
    #];
  #};

  # 1 TB Apple 2.5 HDD
  fileSystems."/mnt/ap1001b" = {
    device = "/dev/disk/by-uuid/c8705ce0-1163-403e-948f-86aa7996c135";
    fsType = "btrfs";
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # Spin down disks (120 = 10 minutes) 
   powerManagement.powerUpCommands = ''    
     ${pkgs.hdparm}/sbin/hdparm -S 120 /dev/disk/by-uuid/c8705ce0-1163-403e-948f-86aa7996c135
   '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luca = {
    isNormalUser = true;
    description = "Luca Maff";
    extraGroups = [ 
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    bitwarden-cli
    borgbackup
    btop
    chezmoi
    gh
    git
    helix
    htop
    iperf3
    mediainfo
    ncdu
    nmap
    pciutils
    powertop
    starship
    syncthing
    tmux
  ];

  programs.fish.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Share with samba
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
      ap1001b = {
        path = "/mnt/ap1001b";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
      #fx2001b = {
        #path = "/mnt/fx2001b";
        #browseable = "yes";
        #"read only" = "no";
        #"guest ok" = "no";
      #};
      #wd5001b = {
        #path = "/mnt/wd5001b";
        #browseable = "yes";
        #"read only" = "no";
        #"guest ok" = "no";
      #};
    };
  };
  # Browsing samba shares with GVFS
  services.gvfs.enable = true;

  # Tailscale
  services.tailscale.enable = true;
  services.tailscale.package = pkgs.tailscale.overrideAttrs { doCheck = false; };

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "luca";
    dataDir = "/home/luca";
    configDir = "/home/luca/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "penguin" = {id = "JAZH2ES-E7YNTS6-NJC5IPZ-CP74LRQ-CMQ2V5A-2LWGZFG-7O7PSYV-L56PKQN"; };
        "hp800g3" = { id = "GV2W7BL-S6HT5OP-EACXTAJ-347P2ZA-ADGDATV-LDFCV3H-4IMT6NL-5HSMYA2"; };
        "moto-g54-luca" = { id = "34SJ4HM-6WEUPL2-HA7OVOD-OKTDUNE-RUGYPFV-VQBM3QR-FYJFYIB-OEP3DQ7"; };
        "nixos-gaming" = { id = "JXZZBVC-4CWRPBW-XOA52RJ-OHHANXK-XIHPRY5-SHTGQUH-UKFQM4M-EZGK3AT"; };
        "zimaboard" = { id = "NXOCWQY-TLCJGYA-UMQRFQM-ZD2LS5X-5RQY4TH-4DXZZC4-KKOWX32-IHPMRQL"; };
      };
      folders = {
        "BigLens" = {
          id = "62prt-kdyws";
          path = "/mnt/ap1001b/history/BigLens";
          devices = [ "hp800g3" "nixos-gaming" "zimaboard" ];
        };
        "EncFS" = {
          id = "j6e46-4z2f7";
          path = "/mnt/ap1001b/media/EncFS";
          devices = [ "hp800g3" "nixos-gaming" "zimaboard" ];
        };
        "MobileLaura" = {
          id = "moto_g_pro_8rrx-photos";
          path = "/mnt/ap1001b/history/MobileLaura";
          devices = [ "hp800g3" "zimaboard" ];
        };
        "MobileLuca" = {
          id = "moto_g32_v6vm-photos";
          path = "/mnt/ap1001b/history/MobileLuca";
          devices = [ "hp800g3" "nixos-gaming" "zimaboard" "moto-g54-luca" ];
        };
        "Music" = {
          id = "an4zy-wuavw";
          path = "/mnt/ap1001b/media/Music";
          devices = [ "hp800g3" "nixos-gaming" "zimaboard" ];
        };
        "WhatsAppLaura" = {
          id = "5i2yp-05gou";
          path = "/mnt/ap1001b/history/WhatsAppLaura";
          devices = [ "hp800g3" "zimaboard" ];
        };
        "WhatsAppLuca" = {
          id = "tysor-1yp0m";
          path = "/mnt/ap1001b/history/WhatsAppLuca";
          devices = [ "hp800g3" "nixos-gaming" "zimaboard" "moto-g54-luca" ];
        };
        "due" = {
          id = "7bjjp-3xtez";
          path = "/mnt/ap1001b/history/due";
          devices = [ "hp800g3" "nixos-gaming" "zimaboard" "penguin" "moto-g54-luca" ];
        };
        "borgRepoMACMINI" = {
          id = "cd9rd-vvyvx";
          path = "/mnt/ap1001b/backup";
          devices = [ "zimaboard" ];
          type = "sendonly";
        };
      };
    };
  };

  # Immich (replace Google Photo)
  services.immich = { 
    enable = false; 
    mediaLocation = "/mnt/fx2001b/immich";
    host = "0.0.0.0"; 
    settings.server.externalDomain = "https://macmini"; 
    openFirewall = true; 
    #settings = {
      #image = {
        #thumbnail.format = "webp";
        #preview.format = "webp";
      #};
    #};
  };

  # Plex (film, TV)
  services.plex = {                                                      
    enable = false;                               
    openFirewall = true;                                                                                      
  };

  # Navidrome (music)
  services.navidrome = {
    enable = false;
    settings = {
      MusicFolder = "/mnt/fx2001b/media/Music/CD";
      Address = "0.0.0.0";
      ImageCacheSize = "1GB";
      LastFM.ApiKey = "0987c2ad94f73d2bba753d7ce9123a65";
      LastFM.Secret = "3debb1b9dd1f2a5a580266ab9859dfeb";
    };
  };

  # Transmission (torrent)
  services.transmission = {
    enable = false;
    user = "luca";
    openFirewall = true;
    openRPCPort = true;
    settings = {
      rpc-bind-address = "0.0.0.0"; #Bind to own IP
      rpc-whitelist = "127.0.0.1 192.168.*.*";  # Whitelist all machines in this network
      rpc-host-whitelist = "macmini.fritz.box";
      incomplete-dir-enabled = true;
      incomplete-dir = "/mnt/fx2001b/media/torrent/incomplete";
      download-dir = "/mnt/fx2001b/media/torrent/download";
      encryption = 2;
      alt-speed-time-enabled = true;
      alt-speed-up = 500;
      alt-speed-down = 500;
      alt-speed-time-begin = 480;
      alt-speed-time-end = 1380;
    };
  };

  # Meal planner                                                                                
  services.mealie = {                                                                                  
    enable = false;                                                                                   
  };

  # Home Assistant
  services.home-assistant = {         
    enable = false;                       
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

  powerManagement.powertop.enable = true;
  
  # Optimising the store
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  
  services.cron.systemCronJobs = [
    #"30 23 * * * root rtcwake -m mem --date +9h"  # auto standby
    #"@reboot root setpci -s 00:1f.0 0xa4.b=0"  # auto restart after power loss
    "00 20 * * * root /run/current-system/sw/bin/shutdown -h now"  # power off at night
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
