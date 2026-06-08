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
  boot.loader.timeout = 7;
  # Use this if /boot becomes full
  boot.loader.systemd-boot.configurationLimit = 16;
  # Setting RTC time standard to localtime, compatible with Windows in its default configuration
  time.hardwareClockInLocalTime = true;

  networking.hostName = "nixos-gaming"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable Wake on Lan
  networking.interfaces.enp11s0.wakeOnLan.enable = true;
  
  # networking.interfaces.enp11s0.useDHCP = false;
  # networking.interfaces.enp11s0 = {
  #   ipv4.addresses = [{
  #     address = "192.168.1.30";
  #     prefixLength = 24;
  #   }];
  # };

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Mount data disk
  # SSD partition
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/b638a9b2-3aa9-4933-a54d-44ef76312f60";
    fsType = "btrfs";
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
      "exec" # Needed by Steam library
    ];
  };

  # Faxiang 2TB SSD
  fileSystems."/mnt/fx2001b" = {
    device = "/dev/disk/by-uuid/56f445ec-2e4c-4360-875a-067d2d9083a0";
    fsType = "btrfs";
    options = [
      "users" # Allows any user to mount and unmount
      "nofail" # Prevent system from failing if this drive doesn't mount
      "exec" # Needed by Steam library
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luca = {
    isNormalUser = true;
    description = "Luca Maff";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [
    #  thunderbird
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "luca";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = true;
  systemd.services."autovt@tty1".enable = true;


  # Enable the OpenSSH daemon.   
  services.openssh.enable = true;


  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ansible
    avidemux
    bitwarden-cli
    bitwarden-desktop
    bottles
    brave
    btop
    chezmoi
    chromium
    colordiff
    compose2nix
    conda
    coreutils
    dmidecode
    distrobox
    encfs
    exfatprogs
    ffmpeg-full
    flameshot
    freecad
    freefilesync
    freetube
    gh
    gimp-with-plugins
    git
    gnome-multi-writer
    gparted
    handbrake
    hdparm
    helix
    heroic
    hfsprogs    
    htop
    iperf3
    keepassxc
    kopia
    libreoffice
    logseq
    lutris
    megasync
    ncdu
    nixd
    onlyoffice-desktopeditors
    gnomeExtensions.appindicator
    gnomeExtensions.forge
    gnomeExtensions.mock-tray
    gnomeExtensions.pano
    gnomeExtensions.system-monitor
    gnomeExtensions.wayland-or-x11
    mangohud
    mangojuice
    pdf4qt
    picard
    pika-backup
    protonup-ng
    protonup-qt
    qbittorrent
    qemu
    qgis
    quickemu
    starship
    subversionClient
    syncthing
    sweethome3d.application
    telegram-desktop
    teams-for-linux
    ticktick
    tmux
    tribler
    udftools
    urbackup-client
    vim
    vlc
    vscodium
    wavemon
    wget
    #whatsie
    #winboat
  ];

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  # Steam
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # nixpkgs.config.permittedInsecurePackages = [
  #   "electron-36.9.5"
  #   "qtwebengine-5.15.19"
  # ];

  environment.variables = {
    JAVA_TOOL_OPTIONS = "-Dcom.eteks.sweethome3d.j3d.useOffScreen3DView=true";
  };

  # open-source implementation of Nvidia’s Moonlight game streaming 
  services.sunshine = {
    enable = false;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Tailscale VPN
  services.tailscale.enable = true;
  services.tailscale.package = pkgs.tailscale.overrideAttrs { doCheck = false; };

  # Teamviewer
  services.teamviewer.enable = false;

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "luca";
    dataDir = "/mnt/data";
    configDir = "/home/luca/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "localhost:8384";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "penguin" = {id = "JAZH2ES-E7YNTS6-NJC5IPZ-CP74LRQ-CMQ2V5A-2LWGZFG-7O7PSYV-L56PKQN"; };
        "hp800g3" = { id = "GV2W7BL-S6HT5OP-EACXTAJ-347P2ZA-ADGDATV-LDFCV3H-4IMT6NL-5HSMYA2"; };
        "moto-g54-luca" = { id = "34SJ4HM-6WEUPL2-HA7OVOD-OKTDUNE-RUGYPFV-VQBM3QR-FYJFYIB-OEP3DQ7"; };
        "macmini" = { id = "NCANLZ5-ZM3WPT5-PE6X36O-YQLOPCR-AUHSJZX-3B74G72-V5F6KLM-XGJ2KQ5"; };
        "zimaboard" = { id = "NXOCWQY-TLCJGYA-UMQRFQM-ZD2LS5X-5RQY4TH-4DXZZC4-KKOWX32-IHPMRQL"; };
      };
      folders = {
        "BigLens" = {
          id = "62prt-kdyws";
          path = "/mnt/data/history/BigLens";
          devices = [ "hp800g3" "macmini" "zimaboard" ];
        };
        "EncFS" = {
          id = "j6e46-4z2f7";
          path = "/mnt/data/media/EncFS";
          devices = [ "hp800g3" "macmini" "zimaboard" ];
        };
        "MobileLuca" = {
          id = "moto_g32_v6vm-photos";
          path = "/mnt/data/history/MobileLuca";
          devices = [ "hp800g3" "macmini" "zimaboard" "moto-g54-luca" ];
        };
        "Music" = {
          id = "an4zy-wuavw";
          path = "/mnt/data/media/Music";
          devices = [ "hp800g3" "macmini" "zimaboard" ];
        };
        "WhatsAppLuca" = {
          id = "tysor-1yp0m";
          path = "/mnt/data/history/WhatsAppLuca";
          devices = [ "hp800g3" "macmini" "zimaboard" "moto-g54-luca" ];
        };
        "due" = {
          id = "7bjjp-3xtez";
          path = "/home/luca/MEGA/due";
          devices = [ "hp800g3" "macmini" "zimaboard" "penguin" "moto-g54-luca" ];
        };
      };
    };
  };

  # Docker (JRC work)
  # virtualisation.docker.enable = true;
  # users.extraGroups.docker.members = [ "luca" ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  environment.sessionVariables = {
    PATH = [ "$HOME/.local/bin" ];
  };

  # Ollama
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };
  services.open-webui.enable = true;

  # KeyPRO
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="fe00", MODE="0660", TAG+="uaccess"
  '';
  

  # Optimising the store
  nix.settings.auto-optimise-store = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
