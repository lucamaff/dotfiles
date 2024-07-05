# dotfiles

## NixOS

Change
networking.hostName = "nixos-laptop"

Add chezmoi

environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    chezmoi
  ];

Run
chezmoi init --apply lucamaff
