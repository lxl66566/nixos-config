{ pkgs, ... }:
{
  # https://wiki.nixos.org/wiki/AMD_GPU
  # for AMD 9060XT GPU

  # do not use opengl! 在 kde 上出现鼠标漂移。
  # hardware.graphics = {
  #   extraPackages = with pkgs; [
  #     rocmPackages.clr.icd
  #     amdvlk
  #   ];
  #   extraPackages32 = with pkgs; [
  #     driversi686Linux.amdvlk
  #   ];
  # };
  # environment.variables.AMD_VULKAN_ICD = "RADV";
  # systemd.tmpfiles.rules =
  #   let
  #     rocmEnv = pkgs.symlinkJoin {
  #       name = "rocm-combined";
  #       paths = with pkgs.rocmPackages; [
  #         rocblas
  #         hipblas
  #         clr
  #       ];
  #     };
  #   in
  #   [
  #     "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  #   ];
}
