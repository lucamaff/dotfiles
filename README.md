# dotfiles

## NixOS

1. Install NixOS

2. Change the hostname and install chezmoi

| Device             | hostname     |
| ------------------ | ------------ |
| Gaming workstation | nixos-gaming |
| Laura's laptop     | nixos-laptop |
| Acer mini laptop   | nixos-acer   |

```fish
sudo nano /etc/nixos/configuration.nix
```

```nix
networking.hostName = "nixos-gaming"
...
environment.systemPackages = with pkgs; [
  bitwarden-cli
  chezmoi
  gh
  git
];
```

```fish
sudo nixos-rebuild switch
```

3. Login to github and bitwarden

```fish
bw login
gh auth login
```

4. Run

```fish
chezmoi init --apply lucamaff
```
