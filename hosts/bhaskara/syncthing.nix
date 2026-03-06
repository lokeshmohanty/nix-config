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
      devices.laptop.id = "E35GV3M-GT4AQEH-DEWAIYP-T6MSAM4-UFC7U4C-PWQHMSM-6XGZW5P-62VIKQM";
      folders = {
        "Projects" = {
          path = "/home/lokesh/Projects";
          devices = [ "laptop" ];
          ignorePatterns = [ ".venv/*" ];
        };
        "Research" = {
          path = "/home/lokesh/Documents/Research";
          devices = [ "laptop" ];
          ignorePatterns = [ ".venv/*" ];
        };
        "Presentations" = {
          path = "/home/lokesh/Documents/Presentations";
          devices = [ "laptop" ];
          ignorePatterns = [ ".venv/*" ];
        };
        "Books" = {
          path = "/home/lokesh/Documents/Books";
          devices = [ "laptop" ];
          ignorePatterns = [ ".venv/*" ];
        };
        "Practice" = {
          path = "/home/lokesh/Desktop/Practice";
          devices = [ "laptop" ];
          ignorePatterns = [ ".venv/*" ];
        };
        "Notebook" = {
          path = "/home/lokesh/Documents/Notebook";
          devices = [ "laptop" ];
          ignorePatterns = [ ".venv/*" ];
        };
      };
    };
  };
}
