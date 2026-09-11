---
applyTo: "**/*"
---

## Conventions

- Templates pin the released package versions consumers actually get; bumping
  a template's pinned version is a template release.
- What a scaffolded project contains must compile against the released
  stack — CI builds every template output.
