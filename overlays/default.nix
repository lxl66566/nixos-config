self: super: {
  mylib = {
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

    # 1. 如果路径存在 -> 正常 import
    # 2. 如果路径不存在 且 default 为 null -> 强行 import（触发 Nix 原生报错）
    # 3. 如果路径不存在 且 default 有值 -> 返回 default
    importOr =
      path: default:
      if builtins.pathExists path then
        import path
      else if default == null then
        import path # 这会触发 "No such file or directory" 错误
      else
        default;
  };
}
