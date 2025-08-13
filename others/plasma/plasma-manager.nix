{ ... }:
{
  programs.plasma = {
    enable = true;
    shortcuts = {
      "ksmserver"."Log Out" = "Ctrl+Alt+Del";
      "kwin"."MoveMouseToFocus" = "Meta+F5";
      "kwin"."Show Desktop" = "Meta+D";
      "kwin"."Walk Through Windows" = "Alt+Tab";
      "services/org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Print";
      "yakuake"."toggle-window-state" = "Meta+R";
    };
    configFile = {
      "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;
      "baloorc"."Basic Settings"."Indexing-Enabled" = false;
      "kcminputrc"."Keyboard"."NumLock" = 0;
      "kcminputrc"."Keyboard"."RepeatDelay" = 394;
      "kcminputrc"."Keyboard"."RepeatRate" = 32.934400000000004;
      "kcminputrc"."Mouse"."X11LibInputXAccelProfileFlat" = true;
      "kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = true;
      "kdeglobals"."KFileDialog Settings"."Show Bookmarks" = false;
      "kdeglobals"."KFileDialog Settings"."Show Full Path" = true;
      "kdeglobals"."KFileDialog Settings"."Show hidden files" = true;
      "kdeglobals"."KFileDialog Settings"."Show Inline Previews" = true;
      "kdeglobals"."KFileDialog Settings"."Show Preview" = false;
      "kdeglobals"."KFileDialog Settings"."Show Speedbar" = true;
      "kdeglobals"."KFileDialog Settings"."Sort by" = "Name";
      "kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
      "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
      "kdeglobals"."KFileDialog Settings"."Sort reversed" = false;
      "kdeglobals"."KFileDialog Settings"."Speedbar Width" = 89;
      "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";
      "kdeglobals"."KScreen"."ScaleFactor" = 1.25;
      "kdeglobals"."KScreen"."ScreenScaleFactors" = "eDP-1=1.25;HDMI-1=1.25;DP-1=1.25;HDMI-2=1.25;";
      "kscreenlockerrc"."Daemon"."LockGrace" = 30;
      "kscreenlockerrc"."Daemon"."Timeout" = 15;
      "kwalletrc"."Wallet"."Enabled" = false;
      "kwinrc"."Desktops"."Number" = 1;
      "kwinrc"."Desktops"."Rows" = 1;
      "kwinrc"."NightColor"."Active" = true;
      "kwinrc"."NightColor"."Mode" = "Constant";
      "kwinrc"."NightColor"."NightTemperature" = 3800;
      "plasma-localerc"."Formats"."LANG" = "zh_CN.UTF-8";
      "plasma-localerc"."Translations"."LANGUAGE" = "zh_CN";
    };
  };
}
