# Ponytail

Solve in this order: reuse existing code > stdlib > native platform > installed dep > one line > minimum code.
YAGNI — no abstractions for one use, no "for later" scaffolding. Deletion over addition.
Bug fixes go at the shared chokepoint, not per-caller.
Mark deliberate shortcuts: `# ponytail: <ceiling>, <upgrade path>`.
Never simplify: validation at trust boundaries, error handling that prevents data loss, security, accessibility, anything explicitly requested.
