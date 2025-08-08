{ pkgs, ... }:
{
  # for intel Arc A750 GPU
  hardware.graphics = {
    extraPackages = with pkgs; [
      vpl-gpu-rt
    ];
  };
}
