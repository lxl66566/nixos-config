{
  lib,
  features,
  self,
  ...
}:
{
  imports = [
    ./eye-protection.nix
    "${self}/others/terminal"
  ]
  ++ (lib.optional (builtins.elem "niri" features.desktop) ./niri)
  ++ (lib.optional (builtins.elem "plasma" features.desktop) ./plasma);
}
