# CratisApp

A [Cratis](https://cratis.io) application built with **Kotlin**, **Spring Boot**, **Cratis Arc** (CQRS: commands, queries and generated TypeScript proxies) and **Cratis Chronicle** (event sourcing). The frontend is **React + Vite** using Cratis Components.

Scaffolded with `dotnet new cratis-kotlin`.

## Prerequisites

- JDK **17** or newer
- Docker (for the local Chronicle development container)
- Node.js 20+ and a package manager (`yarn`, `pnpm` or `npm`)

## Getting started

### 1. Start the infrastructure

```bash
docker-compose up -d
```

This starts a local [Cratis Chronicle](https://github.com/Cratis/Chronicle) development container (with its bundled MongoDB) and an Aspire dashboard for telemetry. The Chronicle API is available at `http://localhost:35000`, the dashboard at `http://localhost:18888`.

### Choosing a database

The template defaults to MongoDB. To scaffold the application with a different database, pass the `--Database` option when creating the project:

```bash
dotnet new cratis-kotlin --Database PostgreSQL
dotnet new cratis-kotlin --Database MsSql
dotnet new cratis-kotlin --Database SQLite
```

Read models are persisted by the Chronicle kernel itself, so the application code does not change — only how the kernel in `docker-compose.yml` stores its data. For MongoDB it uses the embedded server, for PostgreSQL and MsSql it adds a database container to the compose file, and for SQLite it uses a mounted volume file. The read-model sink the client connects with is switched accordingly (MongoDB or SQL).

### 2. Build the backend (this generates the TypeScript proxies)

```bash
./gradlew build
```

The Arc Gradle plugin generates TypeScript proxies from your Kotlin commands and queries into `build/generated/arc-proxies/`. The frontend build consumes these, so run this before starting the frontend tooling.

### 3. Install frontend dependencies

PACKAGE_MGR_INSTALL

### 4. Run it

Backend (Spring Boot on `http://localhost:8080`):

```bash
./gradlew bootRun
```

Frontend dev server (Vite on `http://localhost:9000`, proxying `/api` to the backend):

PACKAGE_MGR_DEV

Open `http://localhost:9000` and try the demo: register items, watch the read model update through the generated query.

## The sample domain

Everything lives in `src/main/kotlin/com/example/somemodule/somefeature/` — a small vertical slice pair that shows the conventions:

| File | What it teaches |
| ---- | --------------- |
| `SomeId.kt` | A strongly-typed identity (`ConceptAs<String>`) instead of a raw `String` |
| `SomeName.kt` | A strongly-typed value (`ConceptAs<String>`) |
| `registration/Registration.kt` | The `Register` command (a `@Command` with a `@CommandKey`), the `Registered` event it appends, and a `@Reactor` observing it |
| `listing/Listing.kt` | The `Listing` read model built by a `@Reducer` from `Registered` events, plus the `all` query exposing it at `GET /api/listings` |

The frontend in `SomeModule/SomeFeature/` shows the React side: a `DataPage` listing over the generated query, and a `CommandDialog` executing the generated command.

Try the endpoints directly:

```bash
curl -sS -X POST http://localhost:8080/api/register \
    -H 'Content-Type: application/json' \
    -d '{"id":"'$(uuidgen)'","name":"Cratis"}'

curl -sS -X QUERY http://localhost:8080/api/listings \
    -H 'Content-Type: application/json' \
    -d '{"arguments":{}}'
```

## Project structure

```
CratisApp/
├── src/main/kotlin/com/example/        — backend sources
│   ├── CratisAppApplication.kt       — Spring Boot entry point
│   ├── ChronicleConfiguration.kt     — Chronicle options and domain artifact registration
│   └── somemodule/somefeature/       — the sample vertical slices
├── src/main/resources/               — application.properties
├── .frontend/                        — Vite + TypeScript configuration
├── SomeModule/                       — frontend vertical slices (React components)
├── build/generated/arc-proxies/      — generated TypeScript proxies (do not edit)
├── docker-compose.yml                — Chronicle dev container + Aspire dashboard
└── build.gradle.kts                  — Gradle build with the Arc plugin
```

## Versions

`io.cratis.arc` (the Gradle plugin) and `io.cratis:cratis` (the one dependency that bundles Arc, its Spring Boot wiring, and the Chronicle integration) both resolve to `latest.release`, so a fresh build always picks up the newest published Cratis release without editing `build.gradle.kts`. Pin an exact version instead only when a build needs to be reproducible against a specific release.

| Dependency | Version |
| ---------- | ------- |
| Kotlin | 2.4.20 |
| Spring Boot | 4.1.1 |
| Java toolchain | 17 |
| Gradle | 9.1.0 |

Upgrade these by bumping them in `build.gradle.kts` and `gradle/wrapper/gradle-wrapper.properties`.

## AI assistance

This project ships with a `.cratis/ai.json` holding its Cratis AI configuration. Make sure the Cratis CLI is installed — see [https://cratis.io/cli](https://cratis.io/cli) — and run:

```bash
cratis ai update
```

This installs the Cratis-owned AI rules, skills, and coding agent integration. Commit the installed content with your project. Re-running `cratis ai update` refreshes only Cratis-managed files.
