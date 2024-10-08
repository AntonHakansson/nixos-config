{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules =
        [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
      kernelModules = [ ];
    };
    kernelParams = [ "mitigations=off" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" = {
    device = "rpool/local/root";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "rpool/local/nix";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/nix/store" = {
    device = "rpool/local/nix-store";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/cache" = {
    device = "rpool/local/cache";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/data" = {
    device = "rpool/safe/data";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D5F9-2BEF";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
    opengl.enable = true;
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      powerManagement.enable = true;
      open = true;
    };
    bluetooth.enable = true;
  };
  services.fstrim.enable = true;

  # Nvidia proprietary drivers
  hakanssn.core.nix.unfreePackages = [ "nvidia-x11" "nvidia-settings" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  home-manager.users.hakanssn = { pkgs, ... }: {
    wayland.windowManager.sway.extraOptions = [ "--unsupported-gpu" ];
  };
  environment.variables = { WLR_NO_HARDWARE_CURSORS = "1"; };

  hardware.nvidia.prime = {
    sync.enable = true;
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };
}
