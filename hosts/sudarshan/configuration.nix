{pkgs, ...}: {
  imports = [
    ../../nixos
  ];

  hardware.bluetooth.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      pkgs.rocmPackages.clr.icd
      pkgs.amdvlk
    ];
  };
  services.xserver.videoDrivers = ["amdgpu"];

  networking.hostName = "sudarshan";

  powerManagement.enable = true;
  services.thermald.enable = true;
  # services.tlp.enable = true;
}
