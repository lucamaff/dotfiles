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

  # 4TB Western Digital data disk
  fileSystems."/mnt/wd4001b" = {
    device = "/dev/disk/by-uuid/e6f1f7e5-f82d-4ade-99b2-edd79eaabaf6";
    fsType = "btrfs";
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # Seagate Barracuda 4TB data disk
  fileSystems."/mnt/sg4001b" = {
    device = "/dev/disk/by-uuid/f49960b7-f5b2-4844-b8ea-244bfbe97aca";
    fsType = "xfs";
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
    ];
  };

  # Spin down disks (120 = 10 minutes) #TODO: change with new disk
  powerManagement.powerUpCommands = '' 
    ${pkgs.hdparm}/sbin/hdparm -S 120 /dev/disk/by-uuid/f49960b7-f5b2-4844-b8ea-244bfbe97aca
    ${pkgs.hdparm}/sbin/hdparm -S 120 /dev/disk/by-uuid/e6f1f7e5-f82d-4ade-99b2-edd79eaabaf6
  '';

  # Snapraid
  services.snapraid = {
    enable = true;
    dataDisks = {
      d1 = "/mnt/wd4001b";
    };
    exclude = [
      "/lost+found/"
      "appdata/"
    ];
    parityFiles = [
      "/mnt/sg4001b/snapraid.parity"
    ];
    contentFiles = [
      "/var/snapraid.content"
      "/mnt/wd4001b/snapraid.content"
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

  networking.hostName = "zimaboard"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
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

# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luca = {
    isNormalUser = true;
    description = "Luca Maff";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
    ncdu
    nmap
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
  services.openssh.allowSFTP = true;

  # Enable tailscale
  services.tailscale.enable = true;
  services.tailscale.package = pkgs.tailscale.overrideAttrs { doCheck = false; };

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
      wd4001b = {
        path = "/mnt/wd4001b";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
      #wd2001b = {
        #path = "/mnt/wd2001b";
        #browseable = "yes";
        #"read only" = "no";
        #"guest ok" = "no";
      #};
    };
  };

  services.syncthing = {
    enable = true;
    user = "luca";
    dataDir = "/mnt/wd4001b";
    configDir = "/home/luca/.config/syncthing";
    openDefaultPorts = true;
    #guiAddress = "zimaboard.tail035a.ts.net:8384";
    guiAddress = "0.0.0.0:8384";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "penguin" = {id = "JAZH2ES-E7YNTS6-NJC5IPZ-CP74LRQ-CMQ2V5A-2LWGZFG-7O7PSYV-L56PKQN"; };
        "hp800g3" = { id = "GV2W7BL-S6HT5OP-EACXTAJ-347P2ZA-ADGDATV-LDFCV3H-4IMT6NL-5HSMYA2"; };
        "moto-g54-luca" = { id = "34SJ4HM-6WEUPL2-HA7OVOD-OKTDUNE-RUGYPFV-VQBM3QR-FYJFYIB-OEP3DQ7"; };
        "nixos-gaming" = { id = "JXZZBVC-4CWRPBW-XOA52RJ-OHHANXK-XIHPRY5-SHTGQUH-UKFQM4M-EZGK3AT"; };
        "macmini" = { id = "NCANLZ5-ZM3WPT5-PE6X36O-YQLOPCR-AUHSJZX-3B74G72-V5F6KLM-XGJ2KQ5"; };
        "PCMamiPapi" = { id = "E6ZAXTG-JD5UBHV-OS2AJ2R-2SUQ6DE-M6BQP4R-U7O6Z4L-U6DYZF7-2USXJAC"; };
      };
      folders = {
        "BigLens" = {
          id = "62prt-kdyws";
          path = "/mnt/wd4001b/history/BigLens";
          devices = [ "hp800g3" "nixos-gaming" "macmini" ];
        };
        "EncFS" = {
          id = "j6e46-4z2f7";
          path = "/mnt/wd4001b/media/EncFS";
          devices = [ "hp800g3" "nixos-gaming" "macmini" ];
        };
        "MobileLaura" = {
          id = "moto_g_pro_8rrx-photos";
          path = "/mnt/wd4001b/history/MobileLaura";
          devices = [ "hp800g3" "macmini" ];
        };
        "MobileLuca" = {
          id = "moto_g32_v6vm-photos";
          path = "/mnt/wd4001b/history/MobileLuca";
          devices = [ "hp800g3" "nixos-gaming" "macmini" "moto-g54-luca" ];
        };
        "Music" = {
          id = "an4zy-wuavw";
          path = "/mnt/wd4001b/media/Music";
          devices = [ "hp800g3" "nixos-gaming" "macmini" ];
        };
        "WhatsAppLaura" = {
          id = "5i2yp-05gou";
          path = "/mnt/wd4001b/history/WhatsAppLaura";
          devices = [ "hp800g3" "macmini" ];
        };
        "WhatsAppLuca" = {
          id = "tysor-1yp0m";
          path = "/mnt/wd4001b/history/WhatsAppLuca";
          devices = [ "hp800g3" "nixos-gaming" "macmini" "moto-g54-luca" ];
        };
        "due" = {
          id = "7bjjp-3xtez";
          path = "/mnt/wd4001b/history/due";
          devices = [ "hp800g3" "nixos-gaming" "macmini" "penguin" "moto-g54-luca" ];
        };
        "CameraPapi" = {
          id = "moto_g8_power_zqnh-photos";
          path = "/mnt/wd4001b/history/CameraPapi";
          devices = [ "hp800g3" "PCMamiPapi" ];
        };
        "WhatsAppPapi" = {
          id = "sd1sl-9kgiw";
          path = "/mnt/wd4001b/history/WhatsAppPapi";
          devices = [ "hp800g3" "PCMamiPapi" ];
        };
        "duplicatiRepoZIMABOARD" = {
          id = "cnyrk-f3qw9";
          path = "/mnt/wd4001b/backup/mamipapi";
          devices = [ "hp800g3" ];
          type = "sendonly";
        };
      };
    };
  };

  services.cron.systemCronJobs = [
      # suspend during the night
      #"30 22 * * * root rtcwake -m mem --date +10h"
      # copy remote repo only overnight
      "33 06 * * * luca syncthing cli config folders cnyrk-f3qw9 paused set true"  # duplicatiRepoZIMABOARD
      "33 23 * * * luca syncthing cli config folders cnyrk-f3qw9 paused set false"
  ];

  powerManagement.powertop.enable = true;

  # Optimising the store
  nix.optimise.automatic = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

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
  system.stateVersion = "24.11"; # Did you read the comment?

}
