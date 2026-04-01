{ ... }:
{
  services.syncthing = {
    enable = true;
    user = "lokesh";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;
    dataDir = "/home/lokesh/.local/syncthing";
    settings = {
      devices.laptop = {
        id = "E35GV3M-GT4AQEH-DEWAIYP-T6MSAM4-UFC7U4C-PWQHMSM-6XGZW5P-62VIKQM";
        addresses = [ "tcp://100.127.108.81:22000" ];
      };
      folders = {
        "Projects" = {
          path = "/home/lokesh/Projects";
          devices = [ "laptop" ];
          ignorePatterns = [
            ".venv/*"
            ".direnv/*"
          ];
        };
        "Research" = {
          path = "/home/lokesh/Documents/Research";
          devices = [ "laptop" ];
          ignorePatterns = [
            ".venv/*"
            ".direnv/*"
          ];
        };
        "Presentations" = {
          path = "/home/lokesh/Documents/Presentations";
          devices = [ "laptop" ];
          ignorePatterns = [
            ".venv/*"
            ".direnv/*"
          ];
        };
        "Books" = {
          path = "/home/lokesh/Documents/Books";
          devices = [ "laptop" ];
          ignorePatterns = [
            ".venv/*"
            ".direnv/*"
          ];
        };
        "Practice" = {
          path = "/home/lokesh/Desktop/Practice";
          devices = [ "laptop" ];
          ignorePatterns = [
            ".venv/*"
            ".direnv/*"
          ];
        };
        "Notebook" = {
          path = "/home/lokesh/Documents/Notebook";
          devices = [ "laptop" ];
          ignorePatterns = [
            ".venv/*"
            ".direnv/*"
          ];
        };
      };
    };
  };
}
