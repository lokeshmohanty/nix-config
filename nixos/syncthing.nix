{ ... }: {
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
        "lab" = { id = "BKTCSPE-QCLARTR-5UVN7OB-NRHFAJI-SG36GWR-6NDDDO7-FLQVPV6-MGIU6AT"; }; 
        "phone" = { id = "VYT5TLD-2QCG3JR-6B2L32R-SHIHGQQ-6ZFR62Q-M32KCDL-MZUXSNS-LNKFCQQ"; };
      };
      folders = {
        "Projects" = {
          path = "/home/lokesh/Projects";
          devices = [ "lab" ];
        };
        "Research" = {
          path = "/home/lokesh/Documents/Research";
          devices = [ "lab" ];
        };
        "Presentations" = {
          path = "/home/lokesh/Documents/Presentations";
          devices = [ "lab" ];
        };
        "Books" = {
          path = "/home/lokesh/Documents/Books";
          devices = [ "lab" ];
        };
        "Courses" = {
          path = "/home/lokesh/Documents/Courses";
          devices = [ "lab" ];
        };
        "Practice" = {
          path = "/home/lokesh/Desktop/Practice";
          devices = [ "lab" ];
        };
        "Org" = {
          path = "/home/lokesh/Documents/Org";
          devices = [ "phone" ];
        };
        "Personal" = {
          path = "/home/lokesh/Documents/Personal";
          devices = [ "phone" ];
        };
        "Roam" = {
          path = "/home/lokesh/Documents/Org/Roam";
          devices = [ "lab" ];
        };
      };
    };
  };
}
