# dotfiles

## NixOS

1. Install NixOS

2. Change the hostname and install chezmoi

| Device             | hostname     |
| ------------------ | ------------ |
| Gaming workstation | steam        |
| Surface Laptop 3   | surface      |
| HP server Azzio    | hpsff        |
| HP server Cuveglio | hp800g3      |

```fish
sudo nano /etc/nixos/configuration.nix
```

```nix
networking.hostName = "surface"
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

3. Login to github

```fish
gh auth login
```

4. Run

```fish
chezmoi init --apply lucamaff
```


## Work servers

1. Install conda

2. Create a minimal environment with chezmoi and few basic packages

```bash
conda create -n chezmoi gh git chezmoi
```

3. Login to bitwarden and github

```bash
gh auth login
```

4. Run

```bash
chezmoi init --apply lucamaff
```
