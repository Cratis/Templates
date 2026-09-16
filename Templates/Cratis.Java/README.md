# CratisApp

A [Cratis](https://cratis.io) application built with **Java**, **Spring Boot**, **Cratis Arc** (CQRS: commands, queries and generated TypeScript proxies) and **Cratis Chronicle** (event sourcing). The frontend is **React + Vite** using Cratis Components.

Scaffolded with `dotnet new cratis-java`.

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

### 2. Build the backend (this generates the TypeScript proxies)

```bash
./gradlew build
```

> `dotnet new` does not preserve the executable bit on `gradlew`. If running it fails with
> "Permission denied", invoke it through a shell instead: `sh ./gradlew build`.

The Arc Gradle plugin generates TypeScript proxies from your Java commands and queries into `build/generated/arc-proxies/`. The frontend build consumes these, so run this before starting the frontend tooling.

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

Everything lives in `src/main/java/com/example/somemodule/somefeature/` — a small vertical slice pair that shows the conventions:

| File | What it teaches |
| ---- | --------------- |
| `SomeId.java` | A strongly-typed identity (`ConceptAs<String>`) instead of a raw `String` |
| `SomeName.java` | A strongly-typed value (`ConceptAs<String>`) |
| `registration/Register.java` | The `Register` command (a `@Command` record with a `@CommandKey`) and the `Registered` event it appends |
| `registration/RegistrationReactor.java` | A `@Reactor` observing `Registered` events |
| `listing/Listing.java` | The `Listing` read model, plus the `all` query exposing it at `GET /api/listings` |
| `listing/ListingReducer.java` | A `@Reducer` building `Listing` from `Registered` events |

The `src/main/kotlin/com/example/PackageMarker.kt` file keeps the Java source package visible while KSP-generated code is compiled in the same source set — leave it in place.

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
├── src/main/java/com/example/          — backend sources
│   ├── CratisAppApplication.java     — Spring Boot entry point
│   ├── ChronicleConfiguration.java   — Chronicle options and domain artifact registration
│   └── somemodule/somefeature/       — the sample vertical slices
├── src/main/kotlin/com/example/        — PackageMarker.kt (KSP requirement, do not delete)
├── src/main/resources/               — application.properties
├── .frontend/                        — Vite + TypeScript configuration
├── SomeModule/                       — frontend vertical slices (React components)
├── build/generated/arc-proxies/      — generated TypeScript proxies (do not edit)
├── docker-compose.yml                — Chronicle dev container + Aspire dashboard
└── build.gradle.kts                  — Gradle build with the Arc plugin
```

## Versions

The template pins the versions it was verified against:

| Dependency | Version |
| ---------- | ------- |
| Cratis Arc (Gradle plugin & `arc-chronicle-spring-boot-starter`) | 7.2.0 |
| Cratis Chronicle (via the starter) | 4.0.0 |
| Kotlin | 2.4.20 |
| Spring Boot | 4.1.1 |
| Java toolchain | 17 |
| Gradle | 9.1.0 |

Upgrade by bumping these in `build.gradle.kts` and `gradle/wrapper/gradle-wrapper.properties`. Keep the Arc Gradle plugin version and the `arc-chronicle-spring-boot-starter` version in sync — the starter pins its verified Chronicle version.

## AI assistance

This project ships with a `.cratis/ai.json` holding its Cratis AI configuration. Make sure the Cratis CLI is installed — see [https://cratis.io/cli](https://cratis.io/cli) — and run:

```bash
cratis ai update
```

This installs the Cratis-owned AI rules, skills, and coding agent integration. Commit the installed content with your project. Re-running `cratis ai update` refreshes only Cratis-managed files.
