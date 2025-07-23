{
  lib,
  pkgs,
  features,
  ...
}:

{
  programs.git.config = {
    safe.directory = "*";
    core = {
      quotepath = false;
      pager = "delta";
      # excludesfile = "~/.gitignore_g";
    };
    push = {
      default = "current";
      autoSetupRemote = true;
      useForceIfIncludes = true;
    };
    pull = {
      ff = "only";
    };
    diff = {
      algorithm = "histogram";
      colorMoved = "default";
    };
    init.defaultBranch = "main";
    interactive.diffFilter = "delta --color-only";
    delta.navigate = true;
    merge.conflictstyle = "diff3";
    rebase.autoSquash = true;
    alias = {
      cs = "commit --signoff";
    };
    pack.threads = 8;
    checkout.workers = 8;
  };
}
