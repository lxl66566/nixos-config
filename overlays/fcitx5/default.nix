# 为了不使用默认的 rime-data，改用我自定义的小鹤音形数据，这里需要 override
# 参考 https://github.com/NixOS/nixpkgs/blob/e4246ae1e7f78b7087dce9c9da10d28d3725025f/pkgs/tools/inputmethods/fcitx5/fcitx5-rime.nix
_:
(_: super: {
  # 小鹤音形配置，配置来自 flypy.com 官方网盘的鼠须管配置压缩包 「小鹤音形“鼠须管”for macOS.zip」
  # 下载链接：https://116-142-255-134.pd1.cjjd19.com:30443/download-cdn.cjjd19.com/123-630/d75b0863/1815256659-0/d75b0863395894c2f8bc5d1209b0a676/c-m39?v=5&t=1720352477&s=172035247718dad17dc0c1020f3aa105ebaefa3cfc&r=5GXOGN&bzc=2&bzs=313831353235363635393a32393834393939383a323032373933363a30&filename=%E5%B0%8F%E9%B9%A4%E9%9F%B3%E5%BD%A2%E2%80%9C%E9%BC%A0%E9%A1%BB%E7%AE%A1%E2%80%9Dfor+macOS.zip
  rime-data = ./rime-data-flypy;
  fcitx5-rime = super.fcitx5-rime.override { rimeDataPkgs = [ ./rime-data-flypy ]; };
})
