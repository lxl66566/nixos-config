{
  lib,
  inputs,
  pkgs,
  feature,
  ...
}:
{
  wsl = {
    enable = true;
    defaultUser = username;
  };
}
