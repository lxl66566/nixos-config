{
  lib,
  pkgs,
  username,
  features,
  config,
  ...
}:
{
  environment.sessionVariables.EDITOR = "nvim";
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
      ];
    };
  };

  home-manager.users."${username}" = {
    home.packages = with pkgs; [ gcc ];

    programs.neovim = {
      enable = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
    };

    xdg.configFile = {
      "nvim" = {
        source = pkgs.fetchFromGitHub {
          owner = "AstroNvim";
          repo = "template";
          rev = "20450d8a65a74be39d2c92bc8689b1acccf2cffe";
          sha256 = "sha256-P6AC1L5wWybju3+Pkuca3KB4YwKEdG7GVNvAR8w+X1I=";
        };
        executable = true;
        recursive = true;
      };
    };
  };
}
