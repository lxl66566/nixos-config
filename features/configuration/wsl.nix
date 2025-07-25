{
  lib,
  inputs,
  pkgs,
  feature,
  username,
  ...
}:
{
  wsl = {
    enable = true;
    defaultUser = username;
  };
}
