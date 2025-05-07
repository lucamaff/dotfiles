# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-macmini"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  networking.interfaces.enp1s0f0 = {
    ipv4.addresses = [{
      address = "192.168.1.2";
      prefixLength = 24;
    }];
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  #fileSystems."/mnt/data" = {
    ##device = "/dev/disk/by-uuid/74eb8300-2ce3-451e-8281-eb3c5258c677";
    #fsType = "ext4";
    #options = [
      #"users" # Allows any user to mount and unmount
      #"nofail" # Prevent system from failing if this drive doesn't mount
    #];
  #};

  fileSystems."/mnt/ap1001b" = {
    device = "/dev/disk/by-uuid/28cd9aa3-77a0-4e59-b0b5-b013b2d08ae7";
    fsType = "ext4";
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luca = {
    isNormalUser = true;
    description = "Luca Maff";
    extraGroups = [ 
      "networkmanager"
      "wheel"
      "podman"
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
    powertop
    starship
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
    };
  };
  # Browsing samba shares with GVFS
  services.gvfs.enable = true;

  services.tailscale.enable = true;

  services.syncthing = {
    enable = true;
    user = "luca";
    dataDir = "/mnt/ap1001b";
    configDir = "/home/luca/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "192.168.1.2:8384";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "hp800g3" = { id = "GV2W7BL-S6HT5OP-EACXTAJ-347P2ZA-ADGDATV-LDFCV3H-4IMT6NL-5HSMYA2"; autoAcceptFolders = true; };
        "moto-g32" = { id = "J43GXHC-7SG4NRM-3OZ5Y3W-QTYBJGS-O6SQX2I-T2U42CR-W4DGE4Q-VKI2XAH"; autoAcceptFolders = true; };
        "nixos-gaming" = { id = "JXZZBVC-4CWRPBW-XOA52RJ-OHHANXK-XIHPRY5-SHTGQUH-UKFQM4M-EZGK3AT"; autoAcceptFolders = true; };
        "zimaboard" = { id = "NXOCWQY-TLCJGYA-UMQRFQM-ZD2LS5X-5RQY4TH-4DXZZC4-KKOWX32-IHPMRQL"; autoAcceptFolders = true; };
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
          devices = [ "hp800g3" "moto-g32" "nixos-gaming" "zimaboard" ];
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
          devices = [ "hp800g3" "moto-g32" "nixos-gaming" "zimaboard" ];
        };
        "due" = {
          id = "7bjjp-3xtez";
          path = "/mnt/ap1001b/history/due";
          devices = [ "hp800g3" "moto-g32" "nixos-gaming" "zimaboard" ];
        };
      };
    };
  };

  # Navidrome
  services.navidrome = {
    enable = false;
    settings = {
      MusicFolder = "/mnt/data/media/Music/CD";
      #DataFolder = "/mnt/data/navidrome/data";
      Address = "0.0.0.0";
      ImageCacheSize = "1GB";
      LastFM.ApiKey = "0987c2ad94f73d2bba753d7ce9123a65";
      LastFM.Secret = "3debb1b9dd1f2a5a580266ab9859dfeb";
    };
  };

  # Plex
  services.plex = {
    enable = false;
    openFirewall = true;
  };

  # Create folder for immich, where immich user can read/write
  #systemd.tmpfiles.rules = [
    #"d /mnt/data/immich 0771 luca immich -"
  #];
  services.immich = {
    enable = false;
    mediaLocation = "/mnt/data/immich";
    host = "nixos-macmini.tail035a.ts.net";
    settings.server.externalDomain = "https://nixos-macmini.tail035a.ts.net";
  };

  services.transmission = {
    enable = false;
    user = "luca";
    openFirewall = true;
    openRPCPort = true;
    settings = {
      rpc-bind-address = "0.0.0.0"; #Bind to own IP
      rpc-whitelist = "127.0.0.1 192.168.*.*";  # Whitelist all machines in this network
      rpc-host-whitelist = "nixos-macmini.fritz.box";
      download-dir = "/mnt/data/media/download";
      encryption = 2;
      alt-speed-time-enabled = true;
      alt-speed-time-begin = 480;
      alt-speed-time-end = 1320;
    };
  };

  # auto standby
  services.cron.systemCronJobs = [
      "30 22 * * * root rtcwake -m mem --date +10h"
  ];

  powerManagement.powertop.enable = true;
  
  # Optimising the store
  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
