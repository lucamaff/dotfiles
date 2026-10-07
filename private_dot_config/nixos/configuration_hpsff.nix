# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 100;

  networking.hostName = "hpsff"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;


  # 4TB Western Digital data disk
  fileSystems."/mnt/wd4001b" = {
    device = "/dev/disk/by-uuid/e6f1f7e5-f82d-4ade-99b2-edd79eaabaf6";
    fsType = "btrfs";
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # 4TB Seagate Barracuda data disk
  fileSystems."/mnt/sg4001b" = {
    device = "/dev/disk/by-uuid/3cd68110-b231-46f3-9f3f-020bed248c73";
    fsType = "btrfs";
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # 5 TB WD external USB disk
  fileSystems."/mnt/wd5001b" = {
    device = "/dev/disk/by-uuid/a3a6e8ee-cac4-46f3-b299-a4ead9b86c63";
    fsType = "xfs";
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # Spin down disks (120 = 10 minutes)
  systemd.services.disk-sleep = {
    description = "Run at boot to set spin down disks timer (120 = 10 minutes)";
    path = [
      pkgs.hdparm
    ];
    # the action taken when the service runs
    script = "hdparm -S 120 /dev/disk/by-uuid/e6f1f7e5-f82d-4ade-99b2-edd79eaabaf6; hdparm -S 120 /dev/disk/by-uuid/3cd68110-b231-46f3-9f3f-020bed248c73; hdparm -S 120 /dev/disk/by-uuid/a3a6e8ee-cac4-46f3-b299-a4ead9b86c63";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # MergerFS to have multiple disk in a single path
  fileSystems."/mnt/hdd" = {
    device = "/mnt/sg4001b:/mnt/wd4001b"; # multiple disks --> device = "/mnt/data1:/mnt/data2";
    fsType = "fuse.mergerfs";
    options = [
      "cache.files=off"        # Disable file caching (recommended for large files)
      "dropcacheonclose=true"  # Drop caches when files are closed
      "moveonenospc=true"      # Move files when source drive is full
      "ignorepponrename=true"  # Don't relocate stuff to another disk if I rename things
      "minfreespace=100G"      # Reserve 100GB free space per drive
      "category.create=mfs"    # path preserving algorithm
    ];
  };

  # Snapraid
  services.snapraid = {
    enable = true;
    dataDisks = {
      d1 = "/mnt/wd4001b";
      d2 = "/mnt/sg4001b";
    };
    exclude = [
      "/lost+found/"
      "appdata/"
    ];
    parityFiles = [
      "/mnt/wd5001b/snapraid.parity"
    ];
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/wd4001b/snapraid.content"
      "/mnt/sg4001b/snapraid.content"
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."luca" = {
    isNormalUser = true;
    description = "Luca Maff";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  # Use fish
  programs.fish.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    bitwarden-cli
    borgbackup
    btop
    chezmoi
    gh
    git
    hdparm
    helix
    htop
    iperf3
    mergerfs
    mergerfs-tools
    ncdu
    tparted
    smartmontools
    starship
    tmux
    zoxide
  ];

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
  services.openssh.allowSFTP = true;

  # Tailscale (VPN)
  services.tailscale.enable = true;

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
      hdd = {
        path = "/mnt/hdd";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };
  # Browsing samba shares with GVFS
  services.gvfs.enable = true;

  services.syncthing = {
    enable = true;
    user = "luca";
    dataDir = "/mnt/hdd";
    configDir = "/home/luca/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "moto-g54-luca" = { id = "34SJ4HM-6WEUPL2-HA7OVOD-OKTDUNE-RUGYPFV-VQBM3QR-FYJFYIB-OEP3DQ7"; };
        "moto-g54-laura" = { id = "7VGWXKO-GI673QT-INRM4FT-PIHWMNN-O4MEIXF-VHTUW3U-CSU5Y2O-WN4MJA6"; };
        "hp800g3" = { id = "GV2W7BL-S6HT5OP-EACXTAJ-347P2ZA-ADGDATV-LDFCV3H-4IMT6NL-5HSMYA2"; };
        "macmini" = { id = "NCANLZ5-ZM3WPT5-PE6X36O-YQLOPCR-AUHSJZX-3B74G72-V5F6KLM-XGJ2KQ5"; };
        "SL3" = { id = "PUIWOMG-SGTQQQU-IMYD4Y4-6QLJHUL-GDYZZ7F-D7B5RQV-M4NJ4KG-5SHFVA3"; };
        "PCMamiPapi" = { id = "E6ZAXTG-JD5UBHV-OS2AJ2R-2SUQ6DE-M6BQP4R-U7O6Z4L-U6DYZF7-2USXJAC"; };
        "minipc" = { id = "DN56SO2-2FPLFIM-EGDDGH2-EAXNVL7-4Z5WBRZ-WBXHFWG-5FRFSSR-VDQBOAK"; };
        "moto-g8 papi" = { id = "5ICHBLQ-EV4DVOK-ZQZUXUD-5Q776NO-QFGJAQV-HDL6VK6-VDFT4O3-73Z5BA2"; };
      };
      folders = {
        "BigLens" = {
          id = "62prt-kdyws";
          path = "/mnt/hdd/history/BigLens";
          devices = [ "hp800g3" "SL3" "macmini" ];
        };
        "EncFS" = {
          id = "j6e46-4z2f7";
          path = "/mnt/hdd/media/EncFS";
          devices = [ "hp800g3" "SL3" "macmini" ];
        };
        "MobileLaura" = {
          id = "moto_g_pro_8rrx-photos";
          path = "/mnt/hdd/history/MobileLaura";
          devices = [ "hp800g3" "macmini" "moto-g54-laura" ];
        };
        "MobileLuca" = {
          id = "moto_g32_v6vm-photos";
          path = "/mnt/hdd/history/MobileLuca";
          devices = [ "hp800g3" "SL3" "macmini" "moto-g54-luca" ];
        };
        "Music" = {
          id = "an4zy-wuavw";
          path = "/mnt/hdd/media/Music";
          devices = [ "hp800g3" "SL3" "macmini" ];
        };
        "WhatsAppLaura" = {
          id = "5i2yp-05gou";
          path = "/mnt/hdd/history/WhatsAppLaura";
          devices = [ "hp800g3" "macmini" "moto-g54-laura" ];
        };
        "WhatsAppLuca" = {
          id = "tysor-1yp0m";
          path = "/mnt/hdd/history/WhatsAppLuca";
          devices = [ "hp800g3" "SL3" "macmini" "moto-g54-luca" ];
        };
        "due" = {
          id = "7bjjp-3xtez";
          path = "/mnt/hdd/history/due";
          devices = [ "hp800g3" "SL3" "macmini" "moto-g54-luca" ];
        };
        "BASB" = {
          id = "3owyw-oilad";
          path = "/mnt/hdd/history/BASB";
          devices = [ "hp800g3" "macmini" "moto-g54-luca" "SL3" ];
        };
        "CameraPapi" = {
          id = "moto_g8_power_zqnh-photos";
          path = "/mnt/hdd/history/CameraPapi";
          devices = [ "hp800g3" "minipc" ];
        };
        "WhatsAppPapi" = {
          id = "sd1sl-9kgiw";
          path = "/mnt/hdd/history/WhatsAppPapi";
          devices = [ "hp800g3" "minipc" ];
        };
      };
    };
  };

  # Immich (replace Google Photo)
  services.immich = {
    enable = true;
    port = 2283;
    host = "0.0.0.0";
    openFirewall = true;
    settings.server.externalDomain = "https://hpsff";
  };
  # Enabling Hardware Accelerated Video Transcoding
  services.immich.accelerationDevices = null;
  users.users.immich.extraGroups = [ "video" "render" ];
  # TODO: remove once in 26.01
  nixpkgs.config.permittedInsecurePackages = [
    "immich-2.7.5"
  ];


  # Torrents
  services.qbittorrent = {
    enable = true;
    user = "luca";
    extraArgs = ["--confirm-legal-notice"];
    webuiPort = 8081;
  };

  # Jellyfin (Movies, TV shows)
  # runs on port 8096
  services.jellyfin = {
    enable = true;
    user = "luca";
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
