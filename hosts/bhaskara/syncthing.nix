{...}: {
  services.syncthing = {
    enable = true;
    user = "lokesh";
    dataDir = "/home/lokesh/.local/share/syncthing";
    configDir = "/home/lokesh/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        "laptop".id = "ZUAVAEV-LA24HLW-EIXNXCB-O7DEVOB-CJWPE22-SH5JKJY-MYCOLMN-EUK5LAS";
      };
      folders = {
        "Projects" = {
          path = "/home/lokesh/Projects";
          devices = ["laptop"];
        };
        "Research" = {
          path = "/home/lokesh/Documents/Research";
          devices = ["laptop"];
        };
        "Presentations" = {
          path = "/home/lokesh/Documents/Presentations";
          devices = ["laptop"];
        };
        "Books" = {
          path = "/home/lokesh/Documents/Books";
          devices = ["laptop"];
        };
        "Courses" = {
          path = "/home/lokesh/Documents/Courses";
          devices = ["laptop"];
        };
        "Practice" = {
          path = "/home/lokesh/Desktop/Practice";
          devices = ["laptop"];
        };
        "Org" = {
          path = "/home/lokesh/Documents/Org";
          devices = ["laptop"];
        };
        "Notebook" = {
          path = "/home/lokesh/Documents/Notebook";
          devices = ["laptop"];
        };
      };
    };
  };
}
