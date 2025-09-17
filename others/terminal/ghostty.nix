{ pkgs, username, ... }:
{
  home-manager.users.${username}.programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    # https://ghostty.org/docs/config/reference
    settings = {
      font-size = 10.5;
      font-family = "Fira Code";
    };
  };
}
