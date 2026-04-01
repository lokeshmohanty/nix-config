{
  self,
  ...
}:
{
  flake.homeConfigurations = {
    "lokesh@server" = self.hostlib.mkHomeHost {
      imports = [ ../home ];
      modules = {
        editor.enable = true;
        shell.enable = true;
        tui.enable = true;
      };
    };
  };
}
