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

  programs.nix-ld = {
    enable = true;
    libraries = [(pkgs.runCommand "steamrun-lib" {} "mkdir $out; ln -s ${pkgs.steam-run.fhsenv}/usr/lib64 $out/lib")];
  };

  powerManagement.enable = true;
  services.thermald.enable = true;
  # services.tlp.enable = true;
}
