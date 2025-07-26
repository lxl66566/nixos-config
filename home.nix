{
  config,
  pkgs,
  plasma-manager,
  nix-gaming,
  lib,
  devicename,
  username,
  features,
  ...
}@inputs:
{
  home.username = username;
  # home.homeDirectory = lib.mkDefault "/home/${username}";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "25.05";
  home.file = {
    ".config/nixpkgs/config.nix".source = ./config/nix-config.nix;
  };
  home.sessionPath = [ "$HOME/.cargo/bin/" ];
  xsession.numlock.enable = true;

  # 递归将某个文件夹中的文件，链接到 Home 目录下的指定位置
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # 递归整个文件夹
  #   executable = true;  # 将其中所有文件添加「执行」权限
  # };

  # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  home.packages =
    with pkgs;

    [
      # lunarvim
      ouch # compress and decompress painlessly
      # iperf3
      # ldns # replacement of `dig`, it provide the command `drill`
      # socat # replacement of openbsd-netcat
      # nmap # A utility for network discovery and security auditing
    ]
    ++ (lib.optionals (!features.mini) [
      impala # tui wireless manager
      trash-cli
      shfmt
      starship
      nix-search-cli
      # gitui
      # podman
      # podman-tui
      # trippy # Network diagnostic TUI tool
      iftop # Display bandwidth usage on a network interface
      cachix
      navi # interactive cli cheatsheet
      btdu
      cargo-binstall
      # v2raya
      jq
      yq-go
      xh
      difftastic
      delta
      xz
      pciutils # lspci
      usbutils # lsusb
      nix-tree
      nix-index
      dust
      tldr
      zellij
    ])
    ++ (lib.optionals (features.like_to_build) [
      dwarfs
    ]);

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      delta.enable = true;
      userName = "lxl66566";
      userEmail = "lxl66566@gmail.com";
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        bind \t forward-word
        # fnm env --use-on-cd --shell fish | source
      '';
      shellAliases = rec {
        e = "$EDITOR";
        l = "eza --all --long --color-scale size --binary --header --time-style=long-iso";
        gp = "git pull";
        gc = "git clone";
        gcm = "git commit --signoff -am";
        py = "python";
        fd = "fd -H";
        nb = "sudo nixos-rebuild switch --show-trace --impure --flake .#${devicename}"; # nixos (re)build, impure is for NUR
        nbf = "nb --fast";
        nd = "nix develop -c $SHELL";
        rv = "revertversion";
        jc = "journalctl";
        sc = "systemctl";
        tp = "trash-put";
      };
      functions = {
        revertversion = ''
          set version $argv[1]
          echo "Reverting version $version ..."
          git push origin :refs/tags/$version
          git tag -d $version
          git tag $version
          git push --tags
        '';
        gfixup = ''
          set commit_hash $argv[1]
          if test -z "$commit_hash"
              set commit_hash 'HEAD'
          end
          git commit -a --fixup $commit_hash
          set rebase_target ""
          if test $commit_hash = 'HEAD'
              set rebase_target 'HEAD~2'
          else
              set rebase_target (string trim -- "$commit_hash")~1
          end
          GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash $rebase_target
        '';
      };
    };
    ssh = {
      enable = !features.mini;
      extraConfig = builtins.readFile ./config/ssh_config;
    };
    atuin = {
      enable = !features.mini;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      flags = [ "--disable-ctrl-r" ];
      settings = {
        auto_sync = true;
        dialect = "uk";
        key_path = "/etc/nixos/config/atuin.key";
        show_preview = true;
        style = "compact";
        sync_frequency = "1h";
        sync_address = "https://api.atuin.sh";
        update_check = false;
      };
    };
    starship = {
      enable = !features.mini;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    bat = {
      enable = !features.mini;
      extraPackages = with pkgs.bat-extras; [
        batgrep
        batman
        # batdiff
        batwatch
        prettybat
      ];
      # config = {
      #   style = "plain";
      # };
    };
    eza = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
        "--all"
        "--long"
        "--binary"
        "--time-style=long-iso"
      ];
      git = true;
      # icons = true;
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      # Replace cd with z and add cdi to access zi
      # options = [ "--cmd cd" ];
    };
    btop = {
      enable = !features.mini;
    };
    feh = {
      # Light-weight image viewer
      enable = !features.mini;
      keybindings = {
        zoom_in = "plus";
        zoom_out = "minus";
        scroll_up = "i";
        scroll_down = "k";
        scroll_right = "j";
        scroll_left = "l";
        delete = "D";
        next_img = "Right";
        prev_img = "Left";
        remove = "d Delete";
        toggle_filenames = "I";
        toggle_info = "i";
        zoom_default = "0";
        zoom_fit = "C-0";
        toggle_fullscreen = "f";
        save_filelist = "F";
      };
    };
    neovim = {
      enable = !features.mini;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
    };
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
}
