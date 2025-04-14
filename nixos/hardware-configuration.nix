{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6a590303-f1e4-4870-9259-7d46be5bee63";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/53C5-BDA6";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/feb6cd5f-fcb9-4431-9e1e-0b62744e733a";}
  ];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp6s0.useDHCP = lib.mkDefault true;

  # # Set your system kind (needed for flakes)
  # nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
