# dotfiles

## NixOS

1. Install NixOS

2. Change the hostname and install chezmoi

```bash
sudo nano /etc/nixos/configuration.nix
```

```
networking.hostName = "nixos-laptop"
...
environment.systemPackages = with pkgs; [
    chezmoi
  ];
```

```bash
sudo nixos-rebuild switch
```

3. Run

```bash
chezmoi init --apply lucamaff
```
