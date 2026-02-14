# NixOS configuration for lxl66566.
# You can find the lastest version in https://github.com/lxl66566/nixos-config.

{
  config,
  inputs,
  lib,
  pkgs,
  devicename,
  username,
  features,
  useBtrfs,
  noProxy,
  ...
}@args:
{
  imports = [
    ./hardware
    ./others
  ]
  ++ features.others;

  networking = lib.mkIf (!features.server.enable) {
    useDHCP = lib.mkDefault true;
    hostName = lib.mkDefault username;
    networkmanager.enable = lib.mkDefault true;
    firewall.enable = lib.mkDefault false;
    # proxy.default = "http://127.0.0.1:20172/";
    proxy.noProxy = noProxy;

    # use https://tool.chinaz.com/dns/ to info host.
    extraHosts = lib.mkIf (!features.wsl) (
      lib.mkDefault ''
        185.199.110.133 raw.githubusercontent.com
        104.244.42.65 twitter.com
      ''
    );
  };
  systemd.network.enable = lib.mkDefault false;

  zramSwap = {
    enable = true;
  };

  # region system settings

  time.hardwareClockInLocalTime = true;
  time.timeZone = lib.mkDefault "Asia/Shanghai";
  documentation.man = {
    generateCaches = false;
    man-db.enable = false;
  };
  console = lib.mkDefault {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-120n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "us";
  };
  system.activationScripts.binbash = {
    deps = [ "binsh" ];
    text = ''
      ln -sfn /bin/sh /bin/bash
    '';
  };

  # region nix

  nix = {
    package = if !features.server.enable then pkgs.lix else pkgs.nix;
    settings = {
      trusted-users = [ username ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      # builders-use-substitutes = true;
      substituters = lib.mkBefore (
        lib.optionals (!(features.server.enable && features.server.type == "remote")) [
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          # "https://mirror.sjtu.edu.cn/nix-channels/store" # it sucks
        ]
        ++ [
          "https://cache.garnix.io"
          "https://mirrors.cernet.edu.cn/nix-channels/store"
          "https://nix-community.cachix.org"
        ]
      );
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc =
      if !(features.server.enable && features.server.type == "remote") then
        {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        }
      else
        {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 1d";
        };
  };

  # region services
  services = {
    btrfs.autoScrub = {
      enable = useBtrfs;
      interval = "15 days";
    };
    beesd.filesystems = lib.mkIf useBtrfs {
      "-" = {
        spec = "LABEL=nixos"; # needs to mark your btrfs fs as `nixos`, btrfs filesystem label / nixos
        hashTableSizeMB = 128;
        extraOptions = [
          "--loadavg-target"
          "5.0"
        ];
      };
    };
    # 为所有可移动的块设备强制 udisks2 使用 sync 挂载选项
    udev.extraRules = ''
      ENV{ID_DRIVE_REMOVABLE}=="1", ENV{UDISKS_MOUNT_OPTIONS_DEFAULTS}+="sync"
    '';
    locate = {
      enable = true;
      package = pkgs.plocate;
      interval = "daily";
      pruneBindMounts = true;
      prunePaths = [
        "/afs"
        "/media"
        "/mnt"
        "/net"
        "/sfs"
        "/udev"
        "/var/lock"
        "/var/spool"
        "/var/tmp"
      ];
      pruneNames = lib.filter (line: line != "" && !lib.strings.hasPrefix "#" (lib.strings.trim line)) (
        lib.map lib.strings.trim (lib.strings.splitString "\n" (builtins.readFile ./config/.gitignore_g))
      );
    };
    dae = {
      enable = !(features.server.as_proxy);
      configFile = pkgs.mylib.configToStoreWithMode {
        configFile = ./config/absx.dae;
        mode = "0600";
      };
      # dae needs 0600 permission, but we cannot source file with permission.
      # related issue: https://github.com/nix-community/home-manager/issues/3090
      # configFile = "/home/absx/.config/absx_.dae";
      assets = with pkgs; [
        v2ray-geoip
        v2ray-domain-list-community
      ];
      # disableTxChecksumIpGeneric = true;
    };
    # 防止过热的守护进程
    thermald.enable = true;
    vnstat.enable = true;
    logrotate.checkConfig = false;

    # minimize: https://nixcademy.com/posts/minimizing-nixos-images/
    speechd.enable = lib.mkForce false;
    orca.enable = lib.mkForce false;
  };

  security = {
    pam = {
      services.sudo.rootOK = true;
      loginLimits = [
        {
          domain = "*";
          type = "soft";
          item = "nofile";
          value = "65535";
        }
        {
          domain = "*";
          type = "hard";
          item = "nofile";
          value = "65535";
        }
      ];
    };

    rtkit.enable = true;
    sudo.extraConfig = ''
      Defaults env_keep += "HTTP_PROXY HTTPS_PROXY"
      Defaults passwd_timeout=999
      Defaults timestamp_timeout=30
    '';
  };

  # region Users and Root

  users.users.${username} = {
    isNormalUser = lib.mkIf (username != "root") true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    shell = pkgs.fish;
    password = lib.mkIf (features.impermanence || !features.server.enable) "1"; # must be set if you use impermanence
  };
  environment = {
    shellAliases = {
      jc = "journalctl";
      sc = "systemctl";
    };
    systemPackages = (
      with pkgs;
      [
        coreutils
        parted
        wget
        fd
        htop
        ripgrep
        curl
        which
        lsof
        file
        # linuxKernel.packages.linux_6_6.cpupower
        nur.repos.lxl66566.git-simple-encrypt
      ]
      ++ (lib.optionals (!features.mini) [
        # busybox
        ncdu
        tree
        gnused # GNU sed
        gawk # GNU awk
        gnutar
        unzip
        nixfmt-rfc-style
        python3
        fastfetchMinimal
        efibootmgr # edit efi boot manager
        ethtool # network card info
        zip
        yazi-unwrapped # TUI file browser
        ltrace # intercepts and records dynamic library calls which are called by an executed process and the signals received by that process
        sysstat # Collection of performance monitoring tools for Linux (such as sar, iostat and pidstat)
        dnsutils # `dig` + `nslookup`
        mkpasswd
        sd
        iotop
        bubblewrap
        skim # RIIR of fzf
        # perf
        docker-compose
        lazydocker
        wol # wake on lan, send packets to wake up computer. to wake up my main device: wol E8:9C:25:9B:44:9D
        try # overlayfs, dry-run before writing to fs
      ])
    );
    sessionVariables = rec {
      NIXPKGS_ALLOW_UNFREE = 1;
    };

    persistence."/oldroot" = lib.mkIf features.impermanence {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        # add this two will break my system!
        # "/etc/shadow"
        # "/etc/passwd"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };
    localBinInPath = true;
  };

  # region programs

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };
    fish.enable = true;
    vim = {
      enable = true;
      defaultEditor = true;
    };
    git = {
      enable = true;
    };
    nix-ld.enable = true; # for vscode server
    # nix cli helper, useful
    nh = {
      enable = true;
      flake = "/etc/nixos";
    };
    ssh = {
      startAgent = lib.mkForce false;
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };

      # If you want to run the docker daemon in rootless mode, you need to specify
      # either the socket path (using thr DOCKER_HOST environment variable) or the
      # CLI context using `docker context` explicitly.
      # https://docs.docker.com/engine/security/rootless/
      # https://docs.docker.com/engine/security/rootless/#client
      # rootless = {
      #   enable = true;
      #   setSocketVariable = true;
      # };
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

  # region home-manager
  home-manager.users.${username} =
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
        GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash --committer-date-is-author-date "$rebase_target"
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
          parallel-disk-usage # fastest disk usage
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
          jq
          xh
          pciutils # lspci
          usbutils # lsusb
          nix-tree
          nix-index
          # dust # disk usage
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
        ]);

      programs = {
        home-manager.enable = true;
        ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks =
            let
              rootServers = {
                xrq = "server.perrykum.top";
                n1 = "192.168.1.2";
                ls = "192.168.10.171";
                claw = "47.79.33.39";
                rfc = "198.176.52.113";
                dedi = "173.254.249.43";
                acck = "156.231.141.178";
              };
            in
            (lib.mapAttrs (host: hostname: {
              hostname = hostname;
              user = "root";
            }) rootServers)
            // (pkgs.mylib.importOr "/etc/me/ssh_config.nix" { })
            // {
              "github.com" = {
                user = "git";
                hostname = "ssh.github.com";
                port = 443;
              };
              "*" = {
                forwardAgent = lib.mkForce false;
                addKeysToAgent = "no";
                identityAgent = null;
                identityFile = "~/.ssh/id_ed25519";
                compression = true;
                hashKnownHosts = false;
                userKnownHostsFile = "/dev/null";
                extraOptions = {
                  StrictHostKeyChecking = "no";
                  LogLevel = "ERROR";
                };
              };
            };
        };
        git = {
          enable = true;
          attributes = lib.mkBefore [ "* text=auto lf" ];
          settings = {
            user = {
              name = "lxl66566";
              email = "lxl66566@gmail.com";
            };
            safe.directory = "*";
            core = {
              quotepath = false;
              excludesfile = "${./config/.gitignore_g}";
              autocrlf = "input";
              ignorecase = false;
              hooksPath = "~/.git-hooks";
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
              rebase = false; # https://t.me/withabsolutex/2610, https://t.me/withabsolutex/2611
              ff = "only";
            };
            diff = {
              # difftastic set in programming.nix
              algorithm = "histogram";
              colorMoved = "plain";
              mnemonicPrefix = true;
              renames = true;
            };
            merge.conflictstyle = lib.mkForce "zdiff3";
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
              pruneTags = false; # This is dangerous！If set to true, it will delete local tags on every fetch.
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
            } --show-trace ${if features.wsl then "-- --impure" else ""}"; # nixos (re)build
            nbo = "sudo nixos-rebuild switch --show-trace --print-build-logs --verbose --flake .#${devicename} ${
              if features.wsl then "--impure" else ""
            }"; # nixos rebuild, o means origin
            nd = "nix develop -c $SHELL";
            ndc = "git checkout nix -- flake.nix flake.lock && nd";
            tp = "trash-put";
            sync = "rsync -aviuzP --compress-choice=zstd --compress-level=3";
            bbwrap = "bwrap --bind / / --dev /dev --proc /proc --tmpfs /tmp";
          };
        };
        atuin = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
          flags = [ "--disable-ctrl-r" ];
          settings = {
            auto_sync = true;
            dialect = "uk";
            key_path = "${./config/atuin.key}";
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
          enable = true;
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
          enable = true;
        };
      };

      services = {
        ssh-agent.enable = lib.mkForce false;
        # gcr-ssh-agent.enable = lib.mkForce false;
      };
    };
}
