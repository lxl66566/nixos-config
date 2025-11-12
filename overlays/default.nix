self: super: {
  mylib = {
    configToStore =
      configFile:
      toString (self.writeText (builtins.baseNameOf configFile) (self.lib.fileContents configFile));

    # 将一个配置文件写入 Nix store，并允许自定义其文件权限。
    #
    # @param 一个属性集，包含以下字段:
    #   - configFile: (string) 源配置文件的路径。
    #   - mode: (string, optional) 八进制表示的文件模式 (例如 "600", "755")。
    #           如果未提供，默认为 "777"。
    #
    # @return 一个 derivation，其 store 路径指向新创建的文件。
    configToStoreWithMode =
      {
        configFile,
        mode ? "777",
      }:
      super.runCommand (builtins.baseNameOf configFile)
        {
          # 在 builder 的 shell 环境中需要 `chmod` 命令。
          # `coreutils` 包含了 chmod。
          nativeBuildInputs = [ super.coreutils ];
        }
        ''
          # 1. `builtins.readFile` 读取文件内容。
          # 2. `builtins.toFile` 将内容写入一个临时文件，并返回其路径。
          # 这可以避免 shell 注入等问题。
          contentPath=${builtins.toFile "content" (builtins.readFile configFile)}

          # 将内容从临时文件复制到最终的输出文件 ($out)。
          cp $contentPath $out

          # 使用传入的 mode 参数设置文件权限。
          chmod ${mode} $out
        '';

    # 将一个二进制文件写入 Nix store，并确保其可执行。
    #
    # @param binaryFile: (string) 源二进制文件的路径。
    #
    # @return 一个 derivation，其 store 路径指向新创建的可执行文件。
    binaryToStore =
      binaryFile:
      super.runCommand (builtins.baseNameOf binaryFile)
        {
          # 在 builder 的 shell 环境中需要 `coreutils` 来提供 `cp` 和 `chmod` 命令。
          nativeBuildInputs = [ super.coreutils ];
        }
        ''
          # 直接将源二进制文件复制到输出路径 ($out)。
          # 源文件路径在 Nix 求值期间是可访问的。
          cp ${binaryFile} $out

          # 为文件添加可执行权限。
          chmod +x $out
        '';
  };
}
