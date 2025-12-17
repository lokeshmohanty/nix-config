{pkgs, ...}: {
  imports = [ ../../system ];

  hardware.bluetooth.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = ["amdgpu"];

  networking.hostName = "sudarshan";
  gaming.enable = true;

  powerManagement.enable = true;
  services.thermald.enable = true;
  # services.tlp.enable = true;
}
