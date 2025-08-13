# nixnix run github:nix-community/disko/latest -- --mode destroy,format,mount disko/main.nix
# or
# disko-run disko/main.nix
let
  defaultMountOption = [
    "compress=zstd:11"
    "ssd"
    "noatime"
    "space_cache=v2"
    "discard=async"
  ];
in
{
  disko = {
    enableConfig = true;
    devices = {
      disk = {
        main-disk = {
          device = "/dev/nvme0n1";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "2G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };

              btrfs = {
                end = "-30G";
                content = {
                  type = "btrfs";
                  subvolumes = {
                    "root" = {
                      mountpoint = "/";
                      mountOptions = defaultMountOption;
                    };
                    "home" = {
                      mountpoint = "/home";
                      mountOptions = defaultMountOption;
                    };
                    "var" = {
                      mountpoint = "/var";
                      mountOptions = defaultMountOption;
                    };
                    "nix" = {
                      mountpoint = "/nix";
                      mountOptions = defaultMountOption;
                    };
                    "userroot" = {
                      mountpoint = "/root";
                      mountOptions = defaultMountOption;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
