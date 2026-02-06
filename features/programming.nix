{
  self,
  lib,
  pkgs,
  username,
  features,
  config,
  ...
}:
{
  config = {
    environment.variables = {
      RUSTC_BOOTSTRAP = 1;
    };
  };
  config.home-manager.users."${username}" = {
    home.file = {
      ".cargo/config.toml".source = "${self}/config/cargo.toml";
      ".gitignore_g".source = "${self}/config/.gitignore_g";
    };
    home.packages =
      with pkgs;
      [
        gcc
        gnumake
        tcpdump
        cmake
        strace
        rustup
        pkg-config
        # llvmPackages_18.clang-tools
        llvmPackages_18.clang-unwrapped
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
        tokei
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
        stylua
        autocorrect
        nftables
        net-tools
        ast-grep
      ]
      ++ (lib.optionals (features.desktop != [ ] && !features.wsl) [
        androidStudioPackages.dev
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
      delta.enable = true;
      difftastic = {
        enable = true;
        git.enable = false;
        options = {
          display = "side-by-side-show-both";
        };
      };
      git.settings = {
        delta.navigate = true;
        alias = {
          dft = "-c diff.external=difft diff";
        };
      };
      mergiraf.enable = true;
    };
  };

}
