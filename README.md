# nixos-config

This repository contains lxl66566's NixOS configuration, initiated on 2024-06-28.

usage: `sudo nixos-rebuild switch --flake .#main` (or using other device name)

## Features

The "features" concept is similar to Rust's feature gates, allowing for flexible enablement and combination of different configurations across various machines.

The `features` directory contains two subdirectories:

- `configuration`: Modules that are merged into `configuration.nix`.
- `home-manager`: Modules that are merged into `home.nix` for Home Manager configurations.

## Encryption

Sensitive data is encrypted using [git-simple-encrypt](https://github.com/lxl66566/git-simple-encrypt). The password is my "complex password".

## Construction

|        Name         |                                            Usage                                            |
| :-----------------: | :-----------------------------------------------------------------------------------------: |
|     `flake.nix`     |          Main entry point, defining different machine configurations and features.          |
|     `features/`     |       Contains modular configurations, as described in the "Features" section above.        |
|     `hardware/`     |                 Contains hardware configurations for my different machines                  |
| `configuration.nix` | A basic system configuration that serves as a foundation before applying specific features. |
|      `iso.nix`      |                   Defines a minimal, self-defined NixOS installation ISO.                   |
|    `mynixpkgs/`     |                      Contains custom Nix packages developed by myself.                      |
|      `others/`      |                                 per-software configurations                                 |
|      `config/`      |               Stores personal configuration files for different applications.               |
|     `overlays/`     |                                  my self-defined functions                                  |
|      `disko/`       |           Disko scripts (definition) used for installation. (currently not used)            |
|      `assets/`      |                                        binary assets                                        |

### Hardware

All of my physical machines has the same partition layout, so I use the `hardware/defaultmount.nix` module for them all.

### ISO

The official installation ISO [sucks](https://absx.pages.dev/articles/linux/nix.html#nixos-%E5%AE%89%E8%A3%85)! So I created my own minimal installation ISO, which is defined in `iso.nix`. It contains some fast scripts to reduce the installation time.

- `dae` service ready to bypass the GFW
- give me a `/dev/nvme0n1p1`, I can initialize subvolumes and mount them in less than 10 seconds
