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
      devices.lab.id = "HQ6HDW5-X6C3VWS-CYRV44J-CCYOENZ-BVYZLYN-VSCFQFU-MYXBB56-AC36ZAG";
      devices.office.id = "ABQJ7BS-BFMPBTG-ONT7GN5-UICS4SX-4F4AFI5-EMVSSNJ-6LA42IQ-SWZCAAJ";
      folders = {
        "Projects" = {
          path = "/home/lokesh/Projects";
          devices = [ "lab" "office" ];
          ignorePatterns = [ ".venv/*" ".direnv/*" ];
        };
        "Research" = {
          path = "/home/lokesh/Documents/Research";
          devices = [ "lab" "office" ];
          ignorePatterns = [ ".venv/*" ".direnv/*" ];
        };
        "Presentations" = {
          path = "/home/lokesh/Documents/Presentations";
          devices = [ "lab" "office" ];
          ignorePatterns = [ ".venv/*" ".direnv/*" ];
        };
        "Books" = {
          path = "/home/lokesh/Documents/Books";
          devices = [ "lab" "office" ];
          ignorePatterns = [ ".venv/*" ".direnv/*" ];
        };
        "Practice" = {
          path = "/home/lokesh/Desktop/Practice";
          devices = [ "lab" "office" ];
          ignorePatterns = [ ".venv/*" ".direnv/*" ];
        };
        "Notebook" = {
          path = "/home/lokesh/Documents/Notebook";
          devices = [ "lab" "office" ];
          ignorePatterns = [ ".venv/*" ".direnv/*" ];
        };
        # "Personal" = {
        #   path = "/home/lokesh/Documents/Personal";
        #   devices = [ "phone" ];
        # };
      };
    };
  };
}
