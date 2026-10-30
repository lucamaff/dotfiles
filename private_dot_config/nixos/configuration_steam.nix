# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz;
in

{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      "${home-manager}/nixos"
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;
  # Use this if /boot becomes full
  boot.loader.systemd-boot.configurationLimit = 20;
  # Setting RTC time standard to localtime, compatible with Windows in its default configuration
  time.hardwareClockInLocalTime = true;

  # mount /tmp inside tmpfs
  boot.tmp.useTmpfs = true;
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
  };

  # improve RAM usage by compressing it
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  fileSystems."/mnt/games" =
    { device = "/dev/disk/by-uuid/66136f66-1ef5-4ed9-808a-425a04119778";
      fsType = "btrfs";
      options = [
        "rw"
        "noatime"          # Velocizza i caricamenti disattivando i timestamp di accesso
        "compress=zstd:1"  # Zstd al livello 1 offre compressione rapidissima quasi a costo zero per la CPU
        "ssd"              # Ottimizza l'allocazione dei blocchi per SSD/NVMe
        "discard=async"    # TRIM continuo e asincrono (ottimo per le performance degli SSD moderni)
        "space_cache=v2"   # Gestione moderna e veloce della cache dello spazio libero
        "autodefrag"       # Evita la frammentazione dei piccoli file di gioco
        "nofail"           # Impedisce il blocco del boot all'avvio se il drive è rimosso o spento
        "x-systemd.automount" # Garantisce che il mount avvenga al primo accesso
      ];
    };
  # Forza i permessi corretti per il tuo utente in modo dichiarativo
  systemd.tmpfiles.rules = [
    "d /mnt/games 0755 luca users - -"
  ];
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/mnt/games" ]; # Applica lo scrub direttamente sul tuo drive
  };


  networking.hostName = "steam";
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;  

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable the KDE Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin = {
    enable = true;
    user = "luca";
  };

  # TODO: this could be use for steam deck like but it's not working
  services.displayManager.defaultSession = "plasma";


  # high performance implementation of a message bus
  services.dbus.implementation = "broker";
  services.irqbalance.enable = true;

  # regular trim SSD
  services.fstrim.enable = true;

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Crucial for running 32-bit games (like Wine/Proton)
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;
    # Use proprietary drivers (better performance for games)
    open = false;
    # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
    nvidiaSettings = true;
    # Enable power management services (required for suspend/hibernate)
    powerManagement.enable = true;
    # Preserve video memory allocation to avoid black screens or freezes on resume
    nvidiaPersistenced = true;
  };

  users.users.luca = {
    isNormalUser = true;
    description = "Luca Maff";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
    shell = pkgs.fish;
  };

  services.openssh.enable = true;

  programs.fish.enable = true;
  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    # Enable Gamescope (the micro-compositor used on the Steam Deck)
    gamescopeSession.enable = true;
  };
  # Optimize system performance for gaming on demand
  programs.gamemode.enable = true;
  # let Steam knows where to find the custom compatibility tools
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  # SteamDeck like
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  # Local AI
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    # Bind to all interfaces on port 11434
    host = "0.0.0.0";
    port = 11434;
    # Optional: preload models, see https://ollama.com/library
    loadModels = [
      "gemma3:4b"
      "llama3:8b"
      "qwen2.5:7b"
      "qwen3.5:9b"
    ];
  };
  networking.firewall.allowedTCPPorts = [ 11434 ];

  # Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  environment.sessionVariables = {
    PATH = [ "$HOME/.local/bin" ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # minimum needed for INFRA
    bitwarden-cli
    chezmoi
    gh
    git

    # terminal
    btop
    curl
    helix
    htop
    starship
    tmux
    wget

    # games
    mangohud
    mangojuice
    protonup-ng
    protonup-qt

    distrobox
  ];


  home-manager.users.luca = { pkgs, ... }:
  let
    plasma-manager = builtins.fetchTarball https://github.com/nix-community/plasma-manager/archive/trunk.tar.gz;
  in
  {
    # The state version is required and should stay at the version you originally installed.
    home.stateVersion = "26.05";

    imports = [
      "${plasma-manager}/modules"
    ];

    programs.plasma = {
      enable = true;

      powerdevil.AC = {
        powerButtonAction = "sleep";
        autoSuspend = {
          action = "sleep";
          idleTimeout = 600;
        };
        whenSleepingEnter = "standbyThenHibernate";
        turnOffDisplay.idleTimeout = "never";
        dimDisplay.enable = false;
      };

      kscreenlocker = {
        autoLock = false;
        lockOnResume = false;
        timeout = 0;
        passwordRequired = false;
      };
    };
  };


  # Optimising the store
  nix.settings.auto-optimise-store = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05";
}
