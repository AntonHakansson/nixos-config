/**
 * Caveman Extension for Pi Coding Agent
 *
 * Inspired by https://github.com/JuliusBrussee/caveman
 * Makes the agent speak like a caveman - cutting ~75% of output tokens
 * while keeping full technical accuracy.
 *
 * Usage:
 * - `/caveman` - Toggle caveman mode on/off
 * - `/caveman lite` - Drop filler, keep grammar (professional)
 * - `/caveman full` - Default caveman mode (drop articles, fragments)
 * - `/caveman ultra` - Maximum compression, telegraphic
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

type CavemanLevel = "off" | "lite" | "full" | "ultra";

let currentLevel: CavemanLevel = "off";

const INSTRUCTIONS: Record<CavemanLevel, string> = {
  off: "",
  lite: `Caveman Lite Mode: Keep grammar. Drop filler words like "just", "really", "basically", "actually", "simply". Remove pleasantries like "sure", "certainly", "of course", "happy to". Professional but no fluff.`,
  full: `Caveman Mode: Drop articles (a, an, the). Drop filler (just, really, basically, actually, simply). Drop pleasantries (sure, certainly, of course). Short synonyms (big not extensive, fix not "implement a solution for"). No hedging. Fragments fine. Technical terms stay exact. Code blocks unchanged. Pattern: [thing] [action] [reason]. [next step].`,
  ultra: `Caveman Ultra Mode: Maximum compression. Telegraphic. Drop almost everything. Technical terms exact. Example: "Inline obj prop → new ref → re-render. useMemo."`,
};

function formatLevel(level: CavemanLevel): string {
  switch (level) {
    case "off": return "Normal mode. Caveman go away.";
    case "lite": return "Caveman Lite active. Drop filler, keep grammar.";
    case "full": return "Caveman mode active. Drop articles, fragments ok.";
    case "ultra": return "Caveman Ultra active. Maximum compression.";
  }
}

export default function (pi: ExtensionAPI) {
  // Register /caveman command
  pi.registerCommand("caveman", {
    description: "Toggle caveman mode - speak like caveman, fewer tokens",
    getArgumentCompletions: (prefix) => {
      const levels: CavemanLevel[] = ["lite", "full", "ultra", "off"];
      const items = levels.map((l) => ({ value: l, label: l }));
      return items.filter((i) => i.value.startsWith(prefix));
    },
    handler: async (args, ctx) => {
      // Trim and lowercase the args
      const levelArg = args?.trim().toLowerCase() || "";

      if (!levelArg) {
        // Toggle between off and full
        currentLevel = currentLevel === "off" ? "full" : "off";
      } else {
        // Extract just the level (first word, handle case like "full\n" or "fullhello")
        const cleanArg = levelArg.split(/\s+/)[0].replace(/[^a-z]/g, "");

        if (["lite", "full", "ultra", "off"].includes(cleanArg)) {
          currentLevel = cleanArg as CavemanLevel;
        } else {
          ctx.ui.notify(`Unknown level: ${args}. Use lite, full, ultra, or off.`, "error");
          return;
        }
      }
      ctx.ui.notify(formatLevel(currentLevel), "info");
    },
  });

  // Apply caveman mode by injecting a user message with instructions
  pi.on("before_agent_start", async (event, ctx) => {
    if (currentLevel === "off") return;

    const instruction = INSTRUCTIONS[currentLevel];
    if (!instruction) return;

    // Inject a user message that contains the caveman instructions
    // This ensures the LLM sees it as part of the conversation
    return {
      message: {
        role: "user",
        content: [{ type: "text", text: `[CAVEMAN MODE: ${instruction}]` }],
        display: false,
      },
    };
  });

  // Reset on new session
  pi.on("session_start", async (_event, ctx) => {
    currentLevel = "off";
  });

  // Auto-detect caveman triggers
  pi.on("input", async (event, ctx) => {
    const text = event.text.toLowerCase();
    const triggers = [
      "caveman mode",
      "talk like caveman",
      "use caveman",
      "less tokens",
      "be brief",
      "fewer tokens",
    ];

    for (const trigger of triggers) {
      if (text.includes(trigger)) {
        // Check for level in text
        let level: CavemanLevel = "full";
        if (text.includes("lite")) level = "lite";
        else if (text.includes("ultra")) level = "ultra";

        currentLevel = level;
        ctx.ui.notify(formatLevel(currentLevel), "info");
        break;
      }
    }

    // Check for stop triggers
    const stopTriggers = ["stop caveman", "normal mode", "normal说话"];
    for (const stop of stopTriggers) {
      if (text.includes(stop)) {
        currentLevel = "off";
        ctx.ui.notify("Caveman go away.", "info");
        break;
      }
    }
  });
}
