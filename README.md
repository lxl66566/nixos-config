# nixos-config

Here's lxl66566's NixOS configuration. I'm new to NixOS (20240628), and going to use it as my major OS.

## encrypting

My key data is encrypted by [git-simple-encrypt](https://github.com/lxl66566/git-simple-encrypt). The password is my "complex password".

## files

|               name                |                             usage                              |
| :-------------------------------: | :------------------------------------------------------------: |
|              config               |                        my config files                         |
|              others               |                    some intergrated modules                    |
|             overlays              |                    (not used) rime overlay                     |
| configuration, flake, hardware... |                              ...                               |
|             home.nix              |                        use home-manager                        |
|              iso.nix              |                 a minimal but self defined iso                 |
|            minimal.nix            | a minimal configuration to reinstall (when nixos fail to boot) |
