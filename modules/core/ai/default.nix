{ config, lib, pkgs, ... }:
let
  # Wrap pi-coding-agent to resolve libasound + libpipewire for /voice.
  pi-with-audio = pkgs.symlinkJoin {
    inherit (pkgs.pi-coding-agent) meta;
    name = "pi-coding-agent-with-audio-${pkgs.pi-coding-agent.version}";
    paths = [ pkgs.pi-coding-agent ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/pi \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.alsa-lib pkgs.pipewire ]}
    '';
  };
in
{
  options.hakanssn.core.ai.enable = lib.mkEnableOption "ai";

  config = lib.mkIf config.hakanssn.core.ai.enable {
    hakanssn.core.zfs.homeCacheLinks = [ ".pi" ];

    home-manager.users.hakanssn = { ... }: {
      programs.herdr.enable = true;
      programs.pi-coding-agent = {
        enable = true;
        package = pi-with-audio;
        extraPackages = [ pkgs.nodejs pkgs.bun pkgs.python3 ];

        settings = {
          defaultProvider = "ollama-cloud";
          defaultModel = "kimi-k3";
          defaultThinkingLevel = "off";
          theme = "dark";
          hideThinkingBlock = true;
          packages = [
            "npm:pi-ollama-cloud"
            "npm:@juicesharp/rpiv-voice"
            "npm:pi-hermes-memory"
          ];
        };
      };

      # Declarative skills and extensions from ./pi/
      home.file.".pi/agent/AGENTS.md".source = ./pi/AGENTS.md;
      home.file.".pi/agent/skills/caveman/SKILL.md".source =
        ./pi/skills/caveman/SKILL.md;
      home.file.".pi/agent/skills/lavish/SKILL.md".source =
        ./pi/skills/lavish/SKILL.md;
      home.file.".pi/agent/extensions/caveman/index.ts".source =
        ./pi/extensions/caveman/index.ts;
    };
  };
}
