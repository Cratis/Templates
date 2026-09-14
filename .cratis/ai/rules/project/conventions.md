---
applyTo: "**/*"
---

## Conventions

- Templates reference Cratis packages with a floating version (`Version="*"`
  in `.csproj`, `latest-development` for the Chronicle dev container image) so
  `dotnet new` always scaffolds against the current released Cratis stack.
  Never pin a template's Cratis package or container references to a fixed
  version — that freezes every future scaffold to whatever was current when
  the template last shipped.
- What a scaffolded project contains must compile against the released
  stack — CI builds every template output. A floating reference means CI is
  what catches drift when an upstream package release breaks the sample code;
  fix the sample or the analyzer-triggering code, not by pinning the version.
- npm/frontend dependencies use caret ranges (`^x.y.z`) sized to the version
  verified working at the time of the change — update them when a template's
  frontend is revisited, not pinned to an exact patch version.
