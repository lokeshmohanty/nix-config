{
  self,
  ...
}:
{
  flake.homeConfigurations = {
    "lokesh@server" = self.hostlib.mkHomeHost {
      imports = [ ../home ];
      modules = {
        ai.enable = true;
        editor.enable = true;
        shell.enable = true;
        tui.enable = true;
      };
    };
  };
}
