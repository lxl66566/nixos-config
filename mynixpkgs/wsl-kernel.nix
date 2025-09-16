{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  lib = pkgs.lib;
in
pkgs.linuxPackagesFor (
  pkgs.buildLinux {
    version = "6.6.87.2";
    modDirVersion = "6.6.87.2";
    src = pkgs.fetchFromGitHub {
      owner = "microsoft";
      repo = "WSL2-Linux-Kernel";
      rev = "linux-msft-wsl-6.6.y";
      sha256 = "sha256-UYPqnn605nPplLqDnEKGZ625K+AahOqy3D1ENQE7d/8=";
    };

    postPatch = ''
      cp Microsoft/config-wsl .config
    '';

    structuredExtraConfig = (
      with lib.kernel;
      {
        # Basic BPF Configuration
        BPF = yes;
        BPF_EVENTS = yes;
        BPF_JIT = yes;
        BPF_JIT_ALWAYS_ON = lib.mkForce yes;
        BPF_STREAM_PARSER = yes;
        BPF_SYSCALL = yes;
        CGROUP_BPF = yes;
        CGROUPS = yes;
        DEBUG_INFO = yes;
        DEBUG_INFO_BTF = yes;
        HAVE_EBPF_JIT = yes;
        KPROBE_EVENTS = yes;
        KPROBES = yes;
        LWTUNNEL_BPF = yes;
        NET = yes;
        NET_CLS_ACT = yes;
        NET_CLS_BPF = module;
        NET_EGRESS = yes;
        NET_INGRESS = yes;
        NET_SCH_INGRESS = module;

        # zram and zswap
        ZRAM = module;
        ZSWAP = yes;
        ZPOOL = yes;
        ZSTD_COMPRESS = lib.mkForce yes;

        # BBR
        TCP_CONG_BBR = module;
      }
    );
  }
)
