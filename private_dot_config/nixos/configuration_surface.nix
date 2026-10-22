# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos//hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "surface"; # Define your hostname.
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

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."luca" = {
    isNormalUser = true;
    description = "Luca Maff";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
      telegram-desktop
    ];
    shell = pkgs.fish;
  };

  # Install firefox.
  programs.firefox.enable = true;

  programs.fish.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    bitwarden-cli
    chezmoi
    git
    gh
    helix
    logseq
    starship
    wget
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
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

  # Syncthing
  services.syncthing = {
    enable = false;
    user = "luca";
    dataDir = "/mnt/data";
    configDir = "/home/luca/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "localhost:8384";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # Optimising the store
  nix.settings.auto-optimise-store = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };

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
