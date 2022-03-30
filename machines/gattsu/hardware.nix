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
        [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_latest;
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
    device = "/dev/disk/by-uuid/F717-B071";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    opengl.enable = true;
    opengl.extraPackages = with pkgs;
      [
        # vaapiVdpau
        libvdpau-va-gl
      ];
    nvidia = {
      package = let
        beta = config.boot.kernelPackages.nvidiaPackages.beta;
        stable = config.boot.kernelPackages.nvidiaPackages.stable;
      in if (lib.versionOlder beta.version stable.version) then
        stable
      else
        beta;
    };
  };
  services.fstrim.enable = true;

  # Nvidia proprietary drivers
  asdf.core.nix.unfreePackages = [ "nvidia-x11" "nvidia-settings" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  home-manager.users.hakanssn = { pkgs, ... }: {
    wayland.windowManager.sway.extraOptions = [ "--unsupported-gpu" ];
  };
  environment.variables = { WLR_NO_HARDWARE_CURSORS = "1"; };

  # Anne Pro 2 keyboard disconnects after inactivity
  # boot with usb quirk HID_QUIRK_ALWAYS_POLL(0x00000400)
  # ref: https://www.reddit.com/r/AnnePro/comments/gruzcb/anne_pro_2_linux_cant_type_after_inactivity/
  boot.kernelParams = [ "usbhid.quirks=0x04D9:0xA292:0x00000400" ];
}
