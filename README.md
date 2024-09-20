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

## NixOS Gaming workstation

1. Install NixOS

2. Change the hostname and install minimal set of tools

```bash
sudo nano /etc/nixos/configuration.nix
```

```
networking.hostName = "nixos-gaming"
...
environment.systemPackages = with pkgs; [
    bitwarden-cli
    gh
    git
    chezmoi
    helix
  ];
```

```bash
sudo nixos-rebuild switch
```

3. Login to github and bitwarden

```bash
bw login
gh auth login
```

4. Run

```bash
chezmoi init --apply lucamaff
```
