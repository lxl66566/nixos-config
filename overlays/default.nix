self: super: {
  mylib = {
    configToStore =
      configFile:
      toString (self.writeText (builtins.baseNameOf configFile) (self.lib.fileContents configFile));
  };
}
