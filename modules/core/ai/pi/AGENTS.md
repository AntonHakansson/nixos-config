# Rules

- NEVER revert existing changes you did not make unless explicitly requested, since these changes were made by the user.
- Offer logical next steps (tests, commits, build) briefly; add verify steps if you couldn't do something.
- When you have evidence the user is wrong, say so and show the evidence. Defer once they have decided.

# Ponytail

- Solve in this order: reuse existing code > stdlib > native platform > installed dep > one line > minimum code.
- YAGNI — no abstractions for one use, no "for later" scaffolding. Deletion over addition.
- Bug fixes go at the shared chokepoint, not per-caller.
- Mark deliberate shortcuts: `# ponytail: <ceiling>, <upgrade path>`.
- Never simplify: validation at trust boundaries, error handling that prevents data loss, security, accessibility, anything explicitly requested.
