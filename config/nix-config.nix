{
  allowUnfree = true;
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
    # intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
    yt-dlp = pkgs.yt-dlp.override { withAlias = true; };
  };
  tarball-ttl = 3600 * 24 * 7;
}
