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
        "phone" = { id = "KFX44SL-S6S375R-BJGJWI7-PM74ONC-MNYVYF4-YNDSESJ-EQWEWKE-JZHHJQN"; };
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
        "Practice" = {
          path = "/home/lokesh/Desktop/Practice";
          devices = [ "lab" ];
        };
        "Org" = {
          path = "/home/lokesh/Documents/Org";
          devices = [ "phone" ];
        };
      };
    };
  };
}
