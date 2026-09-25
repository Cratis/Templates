# CratisAspire

A full-stack web application built with Cratis Arc and Chronicle, orchestrated for local development by an Aspire app host.

## Prerequisites

- .NET 10 SDK (the projects target `net10.0`)
- Docker (the Aspire app host runs Chronicle and any database as containers)
- Node.js `^20.19.0` or `>=22.12.0` and a package manager (yarn, pnpm, or npm)

## Getting started

1. Install the frontend dependencies:

   ```bash
   cd CratisAspire
   yarn install
   cd ..
   ```

   If you use Yarn 2 or later, first add a `.yarnrc.yml` containing `nodeLinker: node-modules` to that folder. With Yarn's default Plug'n'Play mode the frontend build fails with `Cannot find module` errors. npm and pnpm need no extra step.

2. Run the application through the Aspire app host:

   ```bash
   dotnet run --project CratisAspire.Composition
   ```

   Aspire starts Chronicle, its database, and the backend, and prints the dashboard address with a one-time login token, such as `https://localhost:57075/login?t=...`. The port changes between runs; open the link from the terminal to see every resource with its logs and telemetry.

3. For hot reload during frontend development, start the Vite dev server:

   ```bash
   cd CratisAspire
   yarn dev
   ```

   Vite serves the frontend on `http://localhost:9000` and forwards `/api`, `/.cratis`, and `/swagger` to `http://localhost:5000`.

> [!WARNING]
> With the default MongoDB database, the backend resource currently stops a few seconds after it starts. Its log in the dashboard shows `DataAnnotation validation failed for 'MongoDBOptions' members: 'Server' with the error: 'The Server field is required.'`. The app host passes the backend a reference to Chronicle but no MongoDB server address. Verified with Aspire 13.5.3 and Cratis.Chronicle.Aspire 19.6.1.

## Choosing a database

MongoDB is the default. To use another database, pass `--Database` when you create the solution:

```bash
dotnet new cratis-aspire --Database PostgreSQL
dotnet new cratis-aspire --Database MsSql
dotnet new cratis-aspire --Database SQLite
```

The choice determines:

- Which Arc read-model integration the backend uses: MongoDB, or Entity Framework Core with the connection the app host passes in.
- How the app host provisions Chronicle: the development image with its embedded MongoDB for the default, or a PostgreSQL, SQL Server, or SQLite store wired with `WithPostgreSql`, `WithMsSql`, or `WithSqlite`.

## AI assistance

This solution ships with a `.cratis/ai.json` that selects its Cratis AI profiles, languages, and coding-agent harnesses.

1. Make sure the Cratis CLI is installed; see [https://cratis.io/cli](https://cratis.io/cli).
2. From the solution folder, run:

   ```bash
   cratis ai update
   ```

This installs the Cratis-managed AI rules, skills, and harness integration for the selected coding agents, such as `AGENTS.md` and the `.claude/`, `.cursor/`, `.github/`, `.opencode/`, and `.pi/` folders, and records everything it installed in `.cratis/ai.manifest.json`. Commit the installed content with your project. If you scaffolded with `cratis new`, this step has already run.

Re-run `cratis ai update` whenever you want the latest guidance; it only touches Cratis-managed files, never yours. `cratis ai status` shows what is installed and whether a newer revision is available.

## Project Structure

```shell
CratisAspire.sln                          - Solution file
CratisAspire/                             - Main web application
  CratisAspire.csproj                     - .NET project file
  Program.cs                              - Application entry point
  GlobalUsings.cs                         - Global using directives
  CratisAspireDbContext.cs                - Entity Framework Core context for the SQL database choices
  appsettings.json                        - Configuration
  package.json                            - Frontend dependencies and scripts
  tsconfig.json                           - TypeScript configuration
  eslint.config.mjs                       - Lint configuration
  App.tsx, Home.tsx                       - Root React component and home page
  .frontend/                              - Frontend application shell
    index.html                            - HTML entry point
    main.tsx                              - React entry point
    index.css                             - Global styles
    vite.config.ts                        - Vite configuration
  <Module>/                               - A domain module
    <Feature>/                            - A vertical slice
      <Feature>.tsx                       - React composition page
      <Feature>.cs                        - Backend C# code
      index.ts                            - TypeScript barrel export
      <Slice>/                            - Sub-slice
        ...
CratisAspire.Composition/                 - Aspire AppHost (orchestration)
  CratisAspire.Composition.csproj         - Aspire AppHost project file
  Program.cs                              - Aspire resource configuration
CratisAspire.Infrastructure/              - Shared service defaults
  CratisAspire.Infrastructure.csproj      - Infrastructure project file
  Extensions.cs                           - OpenTelemetry, health checks, resilience, service discovery
```

## Architecture

### CratisAspire (Main Application)

The main web application contains all domain logic organized as vertical slices. Each feature has its own folder with:

- C# backend code (commands, events, projections, reactors)
- TypeScript/React frontend components
- Generated proxy files for type-safe API access

### CratisAspire.Composition (Aspire AppHost)

The Aspire AppHost project orchestrates all services. It defines how Chronicle, the backend, and other infrastructure services start up and connect to each other. This is the entry point for running the full application stack.

### CratisAspire.Infrastructure (Service Defaults)

Shared infrastructure configuration applied to all services:

- **OpenTelemetry** — distributed tracing, metrics, and structured logging
- **Health checks** — `/health` and `/alive` endpoints, mapped in the Development environment only
- **Service discovery** — automatic service resolution via Aspire
- **HTTP resilience** — retry policies and circuit breakers

## Vertical Slices

Each feature is organized as a vertical slice: all backend and frontend code for a behavior lives together.

```shell
SomeModule/
  SomeFeature/
    SomeId.cs                 - Strongly-typed identity (EventSourceId<Guid>)
    SomeName.cs               - Domain concept (strongly-typed value)
    SomeFeature.tsx           - React page component
    index.ts                  - Barrel export
    Registration/
      Registration.cs         - Register command, Registered event, reactor
      Registration.ts         - Generated TypeScript proxy for Register
      RegisterDialog.tsx      - React dialog component
      index.ts                - Barrel export
    Listing/
      Listing.cs              - Read model, projection, and AllListings query
      Listing.ts              - Generated TypeScript proxy for the query
      ListingPage.tsx         - React listing page component
      index.ts                - Barrel export
```

## TypeScript proxy generation

The `Cratis` package brings in `Cratis.Arc.ProxyGenerator.Build`, which regenerates the TypeScript proxies on every `dotnet build`. `CratisAspire/CratisAspire.csproj` writes each proxy next to the C# file that declares it and uses the same route settings as `Cratis:Arc:GeneratedApis` in `appsettings.json`; change them together, or the proxies call routes the backend does not map. See the [Arc proxy generator configuration](https://www.cratis.io/arc/backend/csharp/proxy-generation/configuration/).

## Learn More

- [Cratis Arc documentation](https://www.cratis.io/arc/)
- [Arc ASP.NET Core configuration](https://www.cratis.io/arc/backend/csharp/asp-net-core/configuration/)
- [Arc proxy generator configuration](https://www.cratis.io/arc/backend/csharp/proxy-generation/configuration/)
- [Arc model-bound commands](https://www.cratis.io/arc/backend/csharp/commands/model-bound/)
- [Arc model-bound queries](https://www.cratis.io/arc/backend/csharp/queries/model-bound/)
- [Chronicle documentation](https://www.cratis.io/chronicle/)
- [Cratis templates documentation](https://www.cratis.io/templates/)
- [Aspire documentation](https://learn.microsoft.com/en-us/dotnet/aspire/)
