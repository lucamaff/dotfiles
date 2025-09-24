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

  # 4TB Seagate parity disk
  fileSystems."/mnt/diskp" = 
  {
    device = "/dev/disk/by-uuid/f49960b7-f5b2-4844-b8ea-244bfbe97aca"; 
    fsType = "xfs"; 
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  }; 
  
  # 1TB Seagate data disk
  fileSystems."/mnt/sg1001b" = 
  {
    device = "/dev/disk/by-uuid/4c0551bd-936d-4722-9e66-72108c640156"; 
    fsType = "btrfs"; 
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

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

  # 3TB Toshiba data disk
  fileSystems."/mnt/to3001b" = 
  {
    device = "/dev/disk/by-uuid/eab4964d-f202-4874-b7d9-a343e0a6c1ee"; 
    fsType = "btrfs"; 
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # Snapraid
  services.snapraid = {
    enable = true;
    dataDisks = {
      d1 = "/mnt/to3001b";
      d2 = "/mnt/sg2001b";
      d3 = "/mnt/sg1001b";
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
      "/mnt/to3001b/snapraid.content"
      "/mnt/sg2001b/snapraid.content"
      "/mnt/sg1001b/snapraid.content"
    ];
  };

  # MergerFS to have multiple disk in a single path
  fileSystems."/mnt/data" = {
    device = "/mnt/sg1001b:/mnt/sg2001b:/mnt/to3001b"; # multiple disks --> device = "/mnt/data1:/mnt/data2";
    fsType = "fuse.mergerfs";
    options = [
        "cache.files=partial"
        "dropcacheonclose=true"
        "category.create=epmfs" # path preserving algorithm
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
    extraGroups = [ "networkmanager" "wheel" "nextcloud" "podman" ];
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
        "penguin" = {id = "JAZH2ES-E7YNTS6-NJC5IPZ-CP74LRQ-CMQ2V5A-2LWGZFG-7O7PSYV-L56PKQN"; };
        "moto-g54-luca" = { id = "34SJ4HM-6WEUPL2-HA7OVOD-OKTDUNE-RUGYPFV-VQBM3QR-FYJFYIB-OEP3DQ7"; };
        "nixos-gaming" = { id = "JXZZBVC-4CWRPBW-XOA52RJ-OHHANXK-XIHPRY5-SHTGQUH-UKFQM4M-EZGK3AT"; };
        "macmini" = { id = "NCANLZ5-ZM3WPT5-PE6X36O-YQLOPCR-AUHSJZX-3B74G72-V5F6KLM-XGJ2KQ5"; };
        "PCMamiPapi" = { id = "E6ZAXTG-JD5UBHV-OS2AJ2R-2SUQ6DE-M6BQP4R-U7O6Z4L-U6DYZF7-2USXJAC"; };
        "zimaboard" = { id = "NXOCWQY-TLCJGYA-UMQRFQM-ZD2LS5X-5RQY4TH-4DXZZC4-KKOWX32-IHPMRQL"; };
      };
      folders = {
        "BigLens" = {
          id = "62prt-kdyws";
          path = "/mnt/data/history/BigLens";
          devices = [ "nixos-gaming" "macmini" "zimaboard" ];
        };
        "EncFS" = {
          id = "j6e46-4z2f7";
          path = "/mnt/data/media/EncFS";
          devices = [ "nixos-gaming" "macmini" "zimaboard" ];
        };
        "MobileLaura" = {
          id = "moto_g_pro_8rrx-photos";
          path = "/mnt/data/history/MobileLaura";
          devices = [ "macmini" "zimaboard"];
        };
        "MobileLuca" = {
          id = "moto_g32_v6vm-photos";
          path = "/mnt/data/history/MobileLuca";
          devices = [ "nixos-gaming" "macmini" "zimaboard" "moto-g54-luca" ];
        };
        "Music" = {
          id = "an4zy-wuavw";
          path = "/mnt/data/media/Music";
          devices = [ "nixos-gaming" "macmini" "zimaboard" ];
        };
        "WhatsAppLaura" = {
          id = "5i2yp-05gou";
          path = "/mnt/data/history/WhatsAppLaura";
          devices = [ "macmini" "zimaboard" ];
        };
        "WhatsAppLuca" = {
          id = "tysor-1yp0m";
          path = "/mnt/data/history/WhatsAppLuca";
          devices = [ "nixos-gaming" "macmini" "zimaboard" "moto-g54-luca" ];
        };
        "due" = {
          id = "7bjjp-3xtez";
          path = "/mnt/data/history/due";
          devices = [ "nixos-gaming" "macmini" "zimaboard" "penguin" "moto-g54-luca" ];
        };
        "CameraPapi" = {
          id = "moto_g8_power_zqnh-photos";
          path = "/mnt/data/history/CameraPapi";
          devices = [ "PCMamiPapi" "zimaboard" ];
        };
        "WhatsAppPapi" = {
          id = "sd1sl-9kgiw";
          path = "/mnt/data/history/WhatsAppPapi";
          devices = [ "PCMamiPapi" "zimaboard" ];
        };
        "borgRepoHP800G3" = {
          id = "erpf3-5ey2u";
          path = "/mnt/data/backup/borg";
          devices = [ "zimaboard" ];
          type = "sendonly";
        };
        "duplicatiRepoZIMABOARD" = {
          id = "cnyrk-f3qw9";
          path = "/mnt/data/backup/mamipapi/duplicati/remoterepo/zimaboard";
          devices = [ "zimaboard" ];
          type = "receiveonly";
        };
      };    
    };    
  };

  # Tailscale (VPN)
  services.tailscale.enable = true;
  services.tailscale.package = pkgs.tailscale.overrideAttrs { doCheck = false; };

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
      "30 01 * * * root rtcwake -m disk --date +7h"  # auto standby
      "@reboot root sleep 20 && systemctl restart navidrome.service"  # quick hack to wait for all disks
      "@reboot root sleep 22 && systemctl restart syncthing.service"  # quick hack to wait for all disks
      "@reboot root sleep 24 && systemctl restart transmission.service"  # quick hack to wait for all disks
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
