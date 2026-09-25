# CratisApp

A [Cratis](https://cratis.io) application built with **Java**, **Spring Boot**, **Cratis Arc** (CQRS: commands, queries and generated TypeScript proxies) and **Cratis Chronicle** (event sourcing). The frontend is **React + Vite** using Cratis Components.

Scaffolded with `dotnet new cratis --language Java` (or `cratis new cratis --language java`).

## Prerequisites

- A JDK **17**. The build's Gradle toolchain requires Java 17 and does not download one, so a newer JDK on its own fails with `Cannot find a Java installation ... matching: {languageVersion=17 ...}`. Point `JAVA_HOME` at a JDK 17.
- Docker with the Compose plugin (`docker compose`), for the local Chronicle development container
- Node.js `^20.19.0` or `>=22.12.0` and a package manager (`yarn`, `pnpm` or `npm`)

## Getting started

### 1. Start the infrastructure

```bash
docker compose up -d
```

This starts a local [Cratis Chronicle](https://github.com/Cratis/Chronicle) development container (with its bundled MongoDB) and an Aspire dashboard for telemetry. Chronicle listens on port 35000; it is ready when `curl --insecure https://localhost:35000/health` prints `Healthy`, and its Workbench is at `https://localhost:35000` (self-signed development certificate). The dashboard is at `http://localhost:18888`.

> [!CAUTION]
> The compose file publishes its ports on every network interface, and Chronicle runs with well-known development credentials. Use it only on a trusted machine, or prefix each port mapping with `127.0.0.1:` to keep it local.

### Choosing a database

The template defaults to MongoDB. To scaffold the application with a different database, pass the `--Database` option when creating the project:

```bash
dotnet new cratis --language Java --Database PostgreSQL
dotnet new cratis --language Java --Database MsSql
dotnet new cratis --language Java --Database SQLite
```

Read models are persisted by the Chronicle kernel itself, so the application code does not change — only how the kernel in `docker-compose.yml` stores its data. For MongoDB it uses the embedded server, for PostgreSQL and MsSql it adds a database container to the compose file, and for SQLite it uses a mounted volume file. The read-model sink the client connects with is switched accordingly (MongoDB or SQL).

### 2. Build the backend (this generates the TypeScript proxies)

```bash
./gradlew build
```

The Arc Gradle plugin generates TypeScript proxies from your Java commands and queries into `build/generated/arc-proxies/`. The frontend build consumes these, so run this before starting the frontend tooling.

### 3. Install frontend dependencies

Skip this if the scaffold already installed them.

```bash
PACKAGE_MGR_INSTALL
```

If you use Yarn 2 or later, first add a `.yarnrc.yml` containing `nodeLinker: node-modules`. With Yarn's default Plug'n'Play mode the frontend build fails with `Cannot find module` errors.

### 4. Run it

Backend (Spring Boot on `http://localhost:8080`):

```bash
./gradlew bootRun
```

In a second terminal, the frontend dev server (Vite on `http://localhost:9000`, proxying `/api` and `/.cratis` to the backend):

```bash
PACKAGE_MGR_DEV
```

Vite opens `http://localhost:9000`. Open **Demo**, register an item, and watch it appear in the list through the generated query.

`./run.sh` runs steps 1 to 4 in one terminal When it exits, whether you press Ctrl+C or a step fails, it runs `docker compose down`, which removes the containers and, with the default MongoDB storage, every event and read model. Use the manual steps with `docker compose stop` when you want to keep data between runs. It uses yarn when available and falls back to npm; `./run.sh --no-frontend` starts only Chronicle and the backend.

To stop manually, press Ctrl+C in both terminals and run `docker compose down`. With MongoDB, the events and read models live inside the Chronicle container and are removed with it; `docker compose stop` keeps them. Spring Boot listens on every interface; set `server.address=127.0.0.1` in `application.properties` to keep the backend local.

## The sample domain

Everything lives in `src/main/java/com/example/somemodule/somefeature/` — a small vertical slice pair that shows the conventions:

| File | What it teaches |
| ---- | --------------- |
| `SomeId.java` | A strongly-typed identity (`ConceptAs<String>`) instead of a raw `String` |
| `SomeName.java` | A strongly-typed value (`ConceptAs<String>`) |
| `registration/Register.java` | The `Register` command, a `@Command` record with a `@CommandKey` |
| `registration/Registered.java` | The `Registered` event the command appends |
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

The command returns `"isSuccess":true`; the query returns the listing in `data`, such as `[{"id":"...","name":"Cratis"}]`. `GET /api/listings` returns the same result.

## Project structure

```text
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
├── run.sh                            — runs Chronicle, the backend, and the frontend together
└── build.gradle.kts                  — Gradle build with the Arc plugin
```

## Versions

`io.cratis.arc` (the Gradle plugin) and `io.cratis:cratis` (the one dependency that bundles Arc, its Spring Boot wiring, and the Chronicle client) are requested as `latest.release`. Gradle resolves them when it builds, and the Chronicle client version follows from the Arc release. Gradle caches a dynamic version for up to 24 hours by default; `./gradlew build --refresh-dependencies` picks up a newer release immediately. For a reproducible or production build, replace `latest.release` with the exact version you tested, keeping the plugin and the dependency on the same version, or enable Gradle dependency locking.

| Dependency | Version |
| ---------- | ------- |
| Kotlin | 2.4.20 |
| KSP | 2.3.12 |
| Spring Boot | 4.1.1 |
| Java toolchain | 17 |
| Gradle | 9.1.0 |

Upgrade these by bumping them in `build.gradle.kts` and `gradle/wrapper/gradle-wrapper.properties`.

## AI assistance

This project ships with a `.cratis/ai.json` holding its Cratis AI configuration. Make sure the Cratis CLI is installed — see [https://cratis.io/cli](https://cratis.io/cli) — and run:

```bash
cratis ai update
```

This installs the Cratis-managed AI rules, skills, and coding-agent integration. Commit the installed content with your project. Re-running `cratis ai update` refreshes only Cratis-managed files. If you scaffolded with `cratis new`, this step has already run.
