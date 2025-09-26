{
  lib,
  pkgs,
  username,
  features,
  config,
  ...
}:
{
  imports = lib.optionals (!features.wsl) [
    ../../others/sccache.nix
  ];

  config = {
    environment.variables = {
      RUSTC_BOOTSTRAP = 1;
    };
  };
  config.home-manager.users."${username}" = {
    home.file = {
      ".cargo/config.toml".source = ../../config/cargo.toml;
      ".gitignore_g".source = ../../config/.gitignore_g;
      ".gitattributes_g".source = ../../config/.gitattributes_g;
    };
    home.packages =
      with pkgs;
      [
        gcc
        gnumake
        cmake
        rustup
        pkg-config
        llvmPackages_18.clang-tools
        bfg-repo-cleaner
        bun
        fnm
        nodejs_22
        corepack_22
        zig # programming language
        jdk
        pre-commit
        nil # Nix language server
        taplo
        # difftastic # diff tool, better pager and structured diff
        # mise # download and run any dev tools
        # leiningen # clojure package manager
        # clojure # functional language
        # cljfmt
        # jd-gui # java decompiler
        # jd-gui has been removed due to a dependency on the dead JCenter Bintray. Other Java decompilers in Nixpkgs include bytecode-viewer (GUI), cfr (CLI), and procyon (CLI).
        # pipx # python binary package manager
        # octave # scientific computing
        cargo-msrv
        # jmeter
        # postman
        gradle
        typst
        gh
        android-tools
        # ida-free
        libarchive

        podman

        # work
        protobuf
        capnproto
        etcd
        go
        wrk2
      ]
      ++ (lib.optionals (features.desktop != [ ] && !features.wsl) [
        androidStudioPackages.dev
      ])
      ++ (lib.optionals (features.like_to_build) [
        mergiraf # structured merge tool
      ]);

    programs = {
      uv = {
        enable = true;
        settings = {
          index-url = "https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple";
          prerelease = "allow";
        };
      };

      poetry = {
        enable = false; # currently not used. I'm working with uv.
        settings = {
          virtualenvs.create = true;
          virtualenvs.in-project = true;
        };
      };

      direnv = {
        # checks for the existence of a .envrc file (and optionally a .env file) in the current and parent directories
        enable = true;
        enableBashIntegration = true;
        # The option `home-manager.users.absx.programs.direnv.enableFishIntegration' is read-only, but it's set multiple times. Definition values:
        #  - In `/nix/store/z5jb911wf7yzzkxi5zjaspagaw1y02l7-source/modules/programs/direnv.nix': true
        #  - In `/nix/store/bxg0a91gd43banfzvvcfm1mjvikcimk2-source/features/home-manager/programming.nix': true
        # enableFishIntegration = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
        config = {
          load_dotenv = true;
        };
      };

      git = {
        enable = true;
        # user and email are set in home.file
        delta.enable = true;
        extraConfig = {
          safe.directory = "*";
          core = {
            quotepath = false;
            excludesfile = pkgs.mylib.configToStore ../../config/.gitignore_g;
            autocrlf = "input";
            ignorecase = false;
            hooksPath = if features.wsl then "/mnt/c/Users/lxl/.git-hooks" else "~/.git-hooks";
            symlinks = true;
          };
          credential."https://e.coding.net" = {
            provider = "generic";
          };
          filter.lfs = {
            smudge = "git-lfs smudge -- %f";
            process = "git-lfs filter-process";
            required = true;
            clean = "git-lfs clean -- %f";
          };
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
            # external = "difft";
            algorithm = "histogram";
            colorMoved = "plain";
            mnemonicPrefix = true;
            renames = true;
          };
          init.defaultBranch = "main";
          delta.navigate = true;
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
          merge = {
            conflictStyle = "diff3";
            mergiraf = {
              name = "mergiraf";
              driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
            };
          };
          pack.threads = 8;
          checkout.workers = 8;
        };
      };
    };
  };

}
