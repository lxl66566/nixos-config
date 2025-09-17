{ pkgs, username, ... }:
{
  programs.foot = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      main = {
        font = "monospace:size=12";
      };
      scrollback = {
        lines = 100000;
      };
      key-bindings = {
        clipboard-copy = "Control+c XF86Copy";
        clipboard-paste = "Control+v XF86Paste";
      };
    };
  };
}
