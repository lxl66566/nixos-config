# Overlays

这里的内容是抄 [ryan4yin](https://github.com/ryan4yin) 的，不过关于 rime 可能日后会添加一些自己的配置。顺带一提，我看了他的很多博文，是我佩服的人。

呃，用了下 rime 不会用，还是滚回我的 chinese-addon 吧。

Overlays for both NixOS and Nix-Darwin.

If you don't know much about overlays, it is recommended to learn the function and usage of overlays
through [Overlays - NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/nixpkgs/overlays).

1. `default.nix`: the entrypoint of overlays, it execute and import all overlay files in the current
   directory with the given args.
2. `fcitx5`: fcitx5's overlay, add my customized Chinese input method -
   [小鹤音形输入法](https://flypy.com/)
