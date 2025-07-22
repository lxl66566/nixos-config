{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation rec {
  pname = "xmrig";
  version = "6.24.0";

  src = pkgs.fetchFromGitHub {
    owner = "xmrig";
    repo = "xmrig";
    rev = "v${version}";
    sha256 = "sha256-AbiTInOMHZ/YOUyl8IMU62ETZtbSTUqaP4vCJKAOCYM=";
  };

  # 在这里替换 src/donate.h 文件中的捐赠等级
  postPatch = ''
    sed -i 's/kDefaultDonateLevel = 1;/kDefaultDonateLevel = 0;/' src/donate.h
    sed -i 's/kMinimumDonateLevel = 1;/kMinimumDonateLevel = 0;/' src/donate.h
    sed -i 's/\/sbin\/modprobe/modprobe/' src/hw/msr/Msr_linux.cpp
  '';

  # 编译 XMRig 所需的依赖
  buildInputs = with pkgs; [
    cmake
    libuv
    openssl
    hwloc
  ];

  # Nix 会自动处理 'mkdir build', 'cd build', 'cmake ..', 和 'make'
  # 我们只需要确保编译产物被安装到正确的位置
  installPhase = ''
    mkdir -p $out/bin
    cp xmrig $out/bin
  '';

  meta = with pkgs.lib; {
    description = "High performance, open source, cross platform RandomX, KawPow, CryptoNight and AstroBWT CPU/GPU miner & RandomX benchmark.";
    homepage = "https://github.com/xmrig/xmrig";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
