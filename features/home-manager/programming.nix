{
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    rustup
    pkg-config
    sccache
    llvmPackages_18.clang-tools
    uv
    fnm
    # nodejs_22
    # corepack_22
    zig # programming language
    go
    jdk
    # leiningen # clojure package manager
    # clojure # functional language
    # cljfmt
    # jd-gui # java decompiler
    # jd-gui has been removed due to a dependency on the dead JCenter Bintray. Other Java decompilers in Nixpkgs include bytecode-viewer (GUI), cfr (CLI), and procyon (CLI).
    # pipx # python binary package manager
    # octave # scientific computing
    cargo-msrv
    # jmeter
    # postman
    gradle
    typst
    gh
    android-tools
    androidStudioPackages.dev
    # ida-free
    # devenv
    libarchive
  ];
}
