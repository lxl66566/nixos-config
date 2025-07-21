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

## Files

|        Name         |                                            Usage                                            |
| :-----------------: | :-----------------------------------------------------------------------------------------: |
|     `flake.nix`     |          Main entry point, defining different machine configurations and features.          |
|     `features/`     |       Contains modular configurations, as described in the "Features" section above.        |
| `configuration.nix` | A basic system configuration that serves as a foundation before applying specific features. |
|     `home.nix`      |            Manages user-specific configurations and packages using Home Manager.            |
|      `iso.nix`      |                   Defines a minimal, self-defined NixOS installation ISO.                   |
|    `minimal.nix`    |            A minimal graphical configuration used for bootstrapping new systems.            |
|    `mynixpkgs/`     |                      Contains custom Nix packages developed by myself.                      |
|      `others/`      |               Houses various integrated modules for specific functionalities.               |
|      `config/`      |               Stores personal configuration files for different applications.               |
|     `overlays/`     |                                         (not used)                                          |
