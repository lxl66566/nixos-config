{
  config,
  pkgs,
  nix-gaming,
  lib,
  devicename,
  username,
  features,
  ...
}@inputs:

let
  revertversion = pkgs.writeShellScriptBin "rv" ''
    set -euxo pipefail
    if [ $# -ne 1 ]; then
      echo "Usage: revertversion <version>"
      return 1
    fi
    echo "Reverting version $@"
    git push origin :refs/tags/$@
    git tag -d $@
    git tag $@
    git push --tags
  '';
  gfixup = pkgs.writeShellScriptBin "gfixup" ''
    set -euxo pipefail
    commit_hash="''${1:-HEAD}"
    git commit -a --fixup "$commit_hash"

    if [ "$commit_hash" = "HEAD" ]; then
      rebase_target="HEAD~2"
    else
      rebase_target="''${commit_hash}~1"
    fi
    GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash "$rebase_target"
  '';
  record = pkgs.writeShellScriptBin "record" ''
    cmd=$(printf '%q ' "$@")
    script -q -c "$cmd" test.log
  '';
  repeat = pkgs.writeShellScriptBin "repeat" ''
    if [ "$#" -eq 0 ]; then
      echo "usage: $0 <command> [args...]"
      exit 1
    fi
    MAX_ATTEMPTS=10000
    for ((i=1; i<=MAX_ATTEMPTS; i++)); do
      echo "---"
      echo "第 $i 次尝试: 正在执行 '$@'"
      "$@"
      exit_code=$?
      if [ ''${exit_code} -ne 0 ]; then
        echo "---"
        echo "命令在第 $i 次尝试时失败，退出码为 ''${exit_code}。脚本已停止。"
        exit ''${exit_code}
      fi
    done
    echo "命令成功执行了 ''${MAX_ATTEMPTS} 次而未失败。"
  '';
  l = pkgs.writeShellScriptBin "l" ''
    if command -v eza &>/dev/null; then
      eza --all --long --color-scale size --binary --header --time-style=long-iso "$@"
    else
      ls -alF "$@"
    fi
  '';
in
{
  home.username = username;
  # home.homeDirectory = lib.mkDefault "/home/${username}";
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "25.11";
  home.file = {
    # config.lib.file.mkOutOfStoreSymlink: https://nixos-and-flakes.thiscute.world/zh/best-practices/accelerating-dotfiles-debugging
    # but it's a shit
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
      shfmt
      starship
      nix-search-cli
      # gitui
      # podman
      # podman-tui
      # trippy # Network diagnostic TUI tool
      iftop # Display bandwidth usage on a network interface
      navi # interactive cli cheatsheet
      cargo-binstall
      # v2raya
      jq
      xh
      pciutils # lspci
      usbutils # lsusb
      nix-tree
      nix-index
      # dust # disk usage
      parallel-disk-usage # fastest disk usage
      tldr
      zellij
      dysk

      # my bash scripts
      revertversion
      gfixup
      record
      l
      repeat
    ])
    ++ (lib.optionals (features.like_to_build) [
      dwarfs
    ])
    ++ (lib.optionals (features.wsl) [
      proxychains-ng
    ]);

  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      settings = {
        user = {
          name = "lxl66566";
          email = "lxl66566@gmail.com";
        };
        safe.directory = "*";
        core = {
          quotepath = false;
          excludesfile = pkgs.mylib.configToStore ./config/.gitignore_g;
          autocrlf = "input";
          ignorecase = false;
          hooksPath = if features.wsl then "/mnt/c/Users/lxl/.git-hooks" else "~/.git-hooks";
          symlinks = true;
        };
        lfs.enable = true;
        push = {
          default = "current";
          autoSetupRemote = true;
          useForceIfIncludes = true;
          followTags = true;
        };
        pull = {
          autoSetupRemote = true;
          rebase = true;
          ff = "only";
        };
        diff = {
          # difftastic set in programming.nix
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
        init.defaultBranch = "main";
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        alias = {
          cs = "commit --signoff";
        };
        column = {
          ui = "auto";
        };
        branch = {
          sort = "-committerdate";
        };
        tag = {
          sort = "version:refname";
        };
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        help = {
          autocorrect = "prompt";
        };
        commit = {
          verbose = true;
        };
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        pack.threads = 8;
        checkout.workers = 8;
      };
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
        # dust = "pdu";
        sc = "sudo systemctl";
        gp = "git pull";
        gc = "git clone";
        gcm = "git commit --signoff -am";
        py = "python";
        fd = "fd -H";
        nb = "nh os switch . -H ${devicename} ${
          if username == "root" then "--bypass-root-check" else ""
        } -- --impure"; # nixos (re)build, impure is for NUR
        nbo = "sudo nixos-rebuild switch --show-trace --print-build-logs --verbose --impure --flake .#${devicename}"; # nixos rebuild, o means origin
        nd = "nix develop -c $SHELL";
        ndc = "git checkout nix -- flake.nix flake.lock && nd";
        tp = "trash-put";
        sync = "rsync -aviuzP --compress-choice=zstd --compress-level=3";
        bbwrap = "bwrap --bind / / --dev /dev --proc /proc --tmpfs /tmp";
      };
    };
    ssh = {
      enable = !features.mini;
      enableDefaultConfig = false;
      extraConfig = builtins.readFile ./config/ssh_config;
      matchBlocks."*".forwardAgent = lib.mkForce false;
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
        key_path = pkgs.mylib.configToStore ./config/atuin.key;
        show_preview = true;
        style = "compact";
        sync_frequency = "1h";
        sync_address = "https://api.atuin.sh";
        update_check = false;
        history_filter = [
          ''^ls($|(\s+((-([a-zA-Z0-9]|-)+)|"(\.|[^/])[^"]*"|'(\.|[^/])[^']*'|(\.|[^/\s-])[^\s]*))*\s*$)'' # filter ls command with non-absolute pathes
          ''^cd($|\s+('[^/][^']*'|"[^/][^"]*"|[^/\s'"][^\s]*))$'' # filter cd command with non-absolute pathes
          ''/nix/store/.*'' # command contains /nix/store
          ''--cookie[=\s]+.+'' # command contains cookie
        ];
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
        # batman
        # batdiff
        batwatch
        # prettybat # fucking big
      ];
      # config = {
      #   style = "plain";
      # };
    };
    eza = lib.mkIf (!(features.mini)) {
      enable = true;
      enableFishIntegration = false; # This will cause infinite loop
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
  };

  services = {
    ssh-agent.enable = lib.mkForce false;
    # gcr-ssh-agent.enable = lib.mkForce false;
  };
}
