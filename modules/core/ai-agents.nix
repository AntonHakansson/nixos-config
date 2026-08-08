{ config, lib, pkgs, ... }:
{
  options.hakanssn.core.ai-agents.enable = lib.mkEnableOption "ai-agents";

  config = lib.mkIf config.hakanssn.core.ai-agents.enable {
    hakanssn.core.zfs.homeCacheLinks = [ ".pi" ];
    home-manager.users.hakanssn = { ... }: {
      home.packages = with pkgs; [ pi-coding-agent ];
    };
  };
}
