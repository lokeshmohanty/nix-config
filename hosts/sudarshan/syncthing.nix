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
      devices = {
        "lab" = {
          id = "HQ6HDW5-X6C3VWS-CYRV44J-CCYOENZ-BVYZLYN-VSCFQFU-MYXBB56-AC36ZAG";
          # autoAcceptFolders = true;
        };
      };
      folders = {
        "Projects" = {
          path = "/home/lokesh/Projects";
          devices = [ "lab" ];
          ignorePatterns = [ ".venv/*" ];
        };
        "Research" = {
          path = "/home/lokesh/Documents/Research";
          devices = [ "lab" ];
          ignorePatterns = [ ".venv/*" ];
        };
        "Presentations" = {
          path = "/home/lokesh/Documents/Presentations";
          devices = [ "lab" ];
          ignorePatterns = [ ".venv/*" ];
        };
        "Books" = {
          path = "/home/lokesh/Documents/Books";
          devices = [ "lab" ];
          ignorePatterns = [ ".venv/*" ];
        };
        "Practice" = {
          path = "/home/lokesh/Desktop/Practice";
          devices = [ "lab" ];
          ignorePatterns = [ ".venv/*" ];
        };
        "Notebook" = {
          path = "/home/lokesh/Documents/Notebook";
          devices = [ "lab" ];
          ignorePatterns = [ ".venv/*" ];
        };
        # "Personal" = {
        #   path = "/home/lokesh/Documents/Personal";
        #   devices = [ "phone" ];
        # };
      };
    };
  };
}
