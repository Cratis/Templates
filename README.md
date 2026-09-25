# Cratis Templates

[![Nuget](https://img.shields.io/nuget/v/Cratis.Templates?logo=nuget)](http://nuget.org/packages/Cratis.Templates) [![Nuget](https://img.shields.io/nuget/v/Cratis.Templates.Kotlin?logo=nuget)](http://nuget.org/packages/Cratis.Templates.Kotlin) [![Nuget](https://img.shields.io/nuget/v/Cratis.Templates.Java?logo=nuget)](http://nuget.org/packages/Cratis.Templates.Java)

This repository contains all creation templates used by Cratis. It holds `dotnet new` project templates you can use to scaffold new event-sourced and CQRS applications built with [Cratis Chronicle](https://github.com/Cratis/Chronicle) (event-sourcing database and processing runtime) and [Cratis Arc](https://github.com/Cratis/Arc) (CQRS application framework for ASP.NET Core). The JVM templates scaffold the same full-stack application on Spring Boot — in Kotlin or Java — using [Arc for Kotlin and Java](https://github.com/Cratis/Arc.Kotlin). Everything is MIT licensed and free to use.

The templates ship as three NuGet packages. `Cratis.Templates` contains every template, including the Kotlin and Java versions of the `cratis` web application, which `--language Kotlin` or `--language Java` selects. `Cratis.Templates.Kotlin` and `Cratis.Templates.Java` publish the JVM templates on their own. The [Cratis CLI](https://github.com/cratis/cli) can scaffold all of them with `cratis new`.

## Available templates

| Template | Short name | What you get |
| -------- | ---------- | ------------ |
| Cratis Chronicle Console | `cratis-chronicle-console` | A console application connected to Cratis Chronicle |
| Cratis Chronicle Web | `cratis-chronicle-web` | An ASP.NET Core web application connected to Cratis Chronicle |
| Cratis Web Application | `cratis` | A full-stack web application with Arc (commands, queries, TypeScript proxy generation) and a React + Vite frontend using Cratis Components |
| Cratis Aspire Application | `cratis-aspire` | The full-stack web application orchestrated with .NET Aspire |
| Cratis Kotlin Application | `cratis --language Kotlin` | A full-stack web application with Arc and Chronicle on Spring Boot — Kotlin backend, TypeScript proxy generation through the Arc Gradle plugin, and a React + Vite frontend |
| Cratis Java Application | `cratis --language Java` | The same full-stack application authored in Java — Spring Boot backend, TypeScript proxy generation through the Arc Gradle plugin, and a React + Vite frontend |

## Builds

[![Publish](https://github.com/Cratis/Templates/actions/workflows/publish.yml/badge.svg)](https://github.com/Cratis/Templates/actions/workflows/publish.yml)

## How to use

Quick steps to scaffold projects from these templates:

- Install the published templates from NuGet.org (one-time):

```bash
dotnet new install Cratis.Templates
```

- Optional: install a specific version:

```bash
dotnet new install Cratis.Templates@<version>
```

- Optional: install prerelease builds from GitHub Packages. `--store-password-in-clear-text` writes the token unencrypted to your user `NuGet.Config`, and the command line lands in your shell history; use a token with only `read:packages` and remove the source with `dotnet nuget remove source cratis-github` when you are done:

```bash
dotnet nuget add source --name cratis-github --username <github-username> --password <github-token> --store-password-in-clear-text https://nuget.pkg.github.com/cratis/index.json
dotnet new install Cratis.Templates@<version> --nuget-source https://nuget.pkg.github.com/cratis/index.json
```

- List the Cratis templates and note the `Short Name` you want:

```bash
dotnet new list cratis
```

- Create a new project from a template (replace `<shortname>`):

```bash
dotnet new <shortname> -n MyApp -o MyApp
```

- Many templates accept parameters; run `dotnet new <shortname> --help` to see available options. The .NET templates target `net10.0`, so you need the .NET 10 SDK. The Kotlin and Java templates need a JDK 17 to build.
- All application templates (`cratis` — C#, Kotlin, and Java — and `cratis-aspire`) and the Chronicle client templates accept a `--Database` choice — `MongoDB` (default), `PostgreSQL`, `MsSql`, or `SQLite` — selecting which database the Chronicle kernel persists its event stores and read models to, and which read-model package the generated .NET application uses.

> [!IMPORTANT]
> The `cratis` and `cratis-aspire` templates keep selected NuGet references as `Version="*"` in the template source. Their post-creation package actions intentionally resolve those references and pin the generated project to the current latest package versions. The exception is `cratis-aspire` with a SQL database: its post-actions do not pin `Cratis.Arc.EntityFrameworkCore`, which stays at `Version="*"`. The `cratis` template can also install frontend dependencies (yarn/pnpm/npm) as a post-creation step.
>
> Keep frontend dependencies on their latest published releases. The declarations set explicit minimum versions rather than relying only on npm's `latest` tag, which can resolve an older version while satisfying peer dependencies. Components 4 supplies the starter's provider, widgets, and styles directly; no PrimeReact adapter is required. Commit the generated application's lockfile to record the versions you installed. Incompatibilities between current releases should be reported and fixed, not bypassed with `--force` or worked around by downgrading.
>
> In an interactive terminal, `dotnet new` asks before running post-creation actions. When scaffolding **non-interactively** — CI pipelines, scripts, devcontainer `postCreateCommand`, or any context where stdin is not a TTY — opt in explicitly:
>
> ```bash
> dotnet new cratis -n MyApp -o MyApp --allow-scripts yes
> ```
>
> To pin NuGet package versions but skip the regular `cratis` frontend install, pass both `--allow-scripts yes` and `--packageManager none`. The `cratis-aspire` template does not auto-install frontend dependencies; follow the `yarn install` step in its generated `README.md`.

### AI setup in generated projects

Every template ships a `.cratis/ai.json` describing its Cratis AI configuration — the Cratis AI profiles, languages, and coding agent harnesses for that template:

| Template | Profiles | Languages |
| -------- | -------- | --------- |
| `cratis-chronicle-console`, `cratis-chronicle-web` | `cratis/application/chronicle-dotnet` | `csharp` |
| `cratis`, `cratis-aspire` | `cratis/application/csharp` | `csharp`, `typescript` |
| `cratis --language Kotlin` | `cratis/application/kotlin` | `kotlin`, `typescript` |
| `cratis --language Java` | `cratis/application/java` | `java`, `typescript` |

All templates select every harness (`claude`, `codex`, `copilot`, `cursor`, `opencode`, `pi`). After scaffolding with `dotnet new`, which prints a reminder about this, make sure the Cratis CLI is installed (see [https://cratis.io/cli](https://cratis.io/cli)) and run:

```bash
cratis ai update
```

This installs the Cratis-owned AI rules, skills, and harness integration for the selected coding agents — `AGENTS.md` instructions plus `.claude/`, `.cursor/`, `.github/`, `.opencode/`, and `.pi/` integration — and records what it installed in `.cratis/ai.manifest.json`. Commit the installed content with the generated project. Re-running `cratis ai update` refreshes only Cratis-managed files. `cratis new` runs this step itself. The generated `README.md` and the [template documentation](https://www.cratis.io/templates/) describe this in full.

- Uninstall when needed:

```bash
dotnet new uninstall Cratis.Templates
```

### Updating installed templates

To update to the latest version:

```bash
dotnet new update
```

This updates all installed template packages to their latest versions.

To update only Cratis.Templates:

```bash
dotnet new uninstall Cratis.Templates
dotnet new install Cratis.Templates
```

To check which version you currently have installed:

```bash
dotnet new list
```

Look for `Cratis.Templates` in the output to see the installed version.

To update to a specific version:

```bash
dotnet new uninstall Cratis.Templates
dotnet new install Cratis.Templates@<version>
```


## Build & Test Locally

Prerequisites:

- .NET 10 SDK (`global.json` requires 10.0 with `latestFeature` roll-forward)
- Latest stable Node.js and npm, for the templates with a Vite frontend (CI resolves the latest Node release)
- A JDK 17 for building the scaffolded Kotlin and Java applications
- Docker, if you want to run the scaffolded applications against a local Chronicle

### Pack and install the templates locally

To keep your normally installed templates untouched, install into an isolated template-engine hive and pass the same `--debug:custom-hive` to every `dotnet new` command:

```bash
dotnet pack Cratis.Templates.csproj -c Release -o ./nupkgs
dotnet new install ./nupkgs/Cratis.Templates.1.0.0.nupkg --debug:custom-hive ./Testing/hive
dotnet new list cratis --debug:custom-hive ./Testing/hive
```

`Cratis.Templates.Kotlin.csproj` and `Cratis.Templates.Java.csproj` pack the standalone JVM packages the same way. `Testing/` is ignored by Git and excluded from the template projects' compile globs, so it is a safe place for local scaffolds.

To install straight from the template folders into your normal template store, as CI does, run:

```bash
./install-local.sh
```

It uninstalls and reinstalls this repository folder with `dotnet new install <repo> --force`.

### Create a test project from a template

```bash
dotnet new cratis -n MyTestApp -o ./Testing/MyTestApp --allow-scripts yes --debug:custom-hive ./Testing/hive
cd ./Testing/MyTestApp
dotnet build
docker compose up -d
dotnet run
```

For a Kotlin or Java scaffold, add `--language Kotlin` or `--language Java`, then run `./gradlew build` and `./gradlew bootRun` instead of the `dotnet` commands.

### If the generated project includes a frontend (Vite/Node)

```bash
cd path/to/generated/app
npm install
npm run dev
```

### TypeScript compiler and lint tooling

The starters use the latest TypeScript 7 compiler. Following [TypeScript's side-by-side setup](https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/#running-side-by-side-with-typescript-6.0), `@typescript/native` aliases TypeScript 7 and supplies the `tsc` executable used by the build. The `typescript` alias points to the latest `@typescript/typescript6` compatibility package for tools such as typescript-eslint that need the JavaScript compiler API, which TypeScript 7.0 does not provide. This does not switch the build to the older `tsc6` executable.

Check the compiler actually used by the build with `./node_modules/.bin/tsc --version` rather than inferring it from the compatibility package's name.

### Verify the emitted frontend asset layout

```bash
./verify-asset-layout.sh
```

Scaffolds both Vite-based templates, builds their frontends, and checks that every
hashed build artifact lands under `wwwroot/assets/` rather than at the `wwwroot`
root. A flat root layout cannot be expressed as a reverse-proxy, CDN or WAF path
rule — the artifacts are hash-named, change every build and share no prefix — so
the failure only shows up at deployment, as a blank page. CI runs the same script
against the applications it has already generated.

Pass application directories to check ones you have already scaffolded:

```bash
./verify-asset-layout.sh path/to/MyTestApp
```

### Verify the registration identity

The `cratis` and `cratis-aspire` samples return `SomeId`, an `EventSourceId<Guid>`-derived identity, alongside the registered event. This tells Arc to append under that identity and return the same value to the caller. A raw `Guid` in the tuple is only a response value, not an append identity. The generated TypeScript response remains `Guid`.

With .NET 10 and Python 3 installed, check already-scaffolded application directories:

```bash
./verify-registration-identity.sh path/to/MyApp path/to/MyAspireApp/MyAspireApp
```

This regenerates proxies and checks their response type, executes the actual scaffolded registration command, compares its response to the appended event and projected `Listing.Id`, and runs a follow-up command using that response identity. It uses in-process Arc/Chronicle scenarios, not a running Chronicle server; the lookup scenario is seeded with the verified projected instance under its own identity. Test-only packages and runner files stay under the repository's ignored `.ai-work/`; they are not added to generated applications. CI runs this check for both templates.

### Uninstall the local template when finished

```bash
dotnet new uninstall <package-id-or-folder>
```

A custom hive is just a folder: delete `./Testing/hive` to discard it.

Iterate on the template sources, repack, and reinstall to test changes quickly.

## The Cratis ecosystem

This project is part of [Cratis](https://www.cratis.io) — free, MIT-licensed tools for building event-sourced and CQRS applications.

- **[Chronicle](https://github.com/Cratis/Chronicle)** — event-sourcing database and runtime. Orleans-based kernel, pluggable storage (MongoDB default; PostgreSQL, SQL Server, SQLite, in-memory), language-agnostic gRPC contracts. [Docs](https://www.cratis.io/chronicle/)
- **Chronicle clients** — first-class [.NET SDK](https://github.com/Cratis/Chronicle), plus [TypeScript](https://github.com/Cratis/Chronicle.TypeScript), [Kotlin/Java](https://github.com/Cratis/Chronicle.Kotlin), and [Elixir](https://github.com/Cratis/Chronicle.Elixir); [Python](https://github.com/Cratis/Chronicle.Python) coming soon (pre-alpha). AI agents connect through the [Chronicle MCP server](https://github.com/Cratis/Chronicle.Mcp).
- **[Arc](https://github.com/Cratis/Arc)** — opinionated CQRS framework for ASP.NET Core with commands, queries, validation, authorization, and TypeScript proxy generation. Works without event sourcing. [Docs](https://www.cratis.io/arc/)
- **[Components](https://github.com/Cratis/Components)** — React components aligned with Arc patterns. [Docs](https://www.cratis.io/components/)
- **[CLI](https://github.com/Cratis/cli) + Workbench** — inspect and diagnose Chronicle from the terminal or the browser. [Docs](https://www.cratis.io/cli/)
- **Model-first layer (experimental)** — [Studio](https://github.com/Cratis/Studio), [Screenplay](https://github.com/Cratis/Screenplay), [Stage](https://github.com/Cratis/Stage), [Scene](https://github.com/Cratis/Scene), [Prologue](https://github.com/Cratis/Prologue)
- **Supporting** — [Fundamentals](https://github.com/Cratis/Fundamentals), [Specifications](https://github.com/Cratis/Specifications), [Synopsis](https://github.com/Cratis/Synopsis), [Lens](https://github.com/Cratis/Lens), [Narrator](https://github.com/Cratis/Narrator), and free [AI tooling](https://github.com/Cratis/AI) (preview); [Ensemble](https://github.com/Cratis/Ensemble) coming soon (pre-release)
- **[Samples](https://github.com/Cratis/Samples)** — runnable event sourcing and CQRS samples for the whole stack

Everything Cratis publishes today is MIT licensed and free to use.
