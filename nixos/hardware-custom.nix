{ pkgs, config, ... }: {
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    # open = true;
    nvidiaSettings = true;
    # package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  };
  environment.systemPackages = with pkgs; [
    # linuxPackages.nvidia_x11_legacy470
    # cudaPackages_11.cudatoolkit
  ];
  # specialisation = {
  #   nvidia.configuration = {
  #     boot.blacklistedKernelModules = [ "nouveau" ];
  #   };
  # };
  # services.xserver.videoDrivers = [ "nvidiaLegacy470" ];
}
