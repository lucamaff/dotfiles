# dotfiles

## NixOS

1. Install NixOS

2. Change the hostname and install chezmoi

```bash
sudo nano /etc/nixos/configuration.nix
```

| Device             | hostname     |
| ------------------ | ------------ |
| Gaming workstation | nixos-gaming |
| Laura's laptop     | nixos-laptop |
| Acer mini laptop   | nixos-acer   |

```
networking.hostName = "nixos-gaming"
...
environment.systemPackages = with pkgs; [
  bitwarden-cli
  chezmoi
  gh
  git
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
