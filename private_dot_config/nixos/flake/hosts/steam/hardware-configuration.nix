{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "ehci_pci" "uas" "virtio_pci" "virtio_blk" "virtio_scsi" "ata_piix" "sdhci_pci" "mmc_block" "thunderbolt" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2596451f-2b04-4783-9aee-2691a937d07d";
      fsType = "btrfs";
      options = [ "rw" "relatime" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" "subvol=/@" ];
    };

  fileSystems."/.snapshots" =
    { device = "/dev/disk/by-uuid/2596451f-2b04-4783-9aee-2691a937d07d";
      fsType = "btrfs";
      options = [ "rw" "relatime" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" "subvol=/@.snapshots" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/2596451f-2b04-4783-9aee-2691a937d07d";
      fsType = "btrfs";
      options = [ "rw" "relatime" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" "subvol=/@nix" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/2596451f-2b04-4783-9aee-2691a937d07d";
      fsType = "btrfs";
      options = [ "rw" "relatime" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" "subvol=/@home" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/2596451f-2b04-4783-9aee-2691a937d07d";
      fsType = "btrfs";
      options = [ "rw" "relatime" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" "subvol=/@log" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5817-CAF2";
      fsType = "vfat";
      options = [ "rw" "relatime" "fmask=0022" "dmask=0022" "codepage=437" "iocharset=ascii" "shortname=mixed" "utf8" "errors=remount-ro" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/2596451f-2b04-4783-9aee-2691a937d07d";
      fsType = "btrfs";
      options = [ "subvol=/@swap" ];
    };
  swapDevices = [ { device = "/swap/swapfile"; } ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
