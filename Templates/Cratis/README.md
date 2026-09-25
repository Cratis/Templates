# CratisApp

A full-stack web application built with Cratis Arc and Chronicle: an ASP.NET Core backend with model-bound commands and queries, Chronicle for event sourcing, and a React + Vite frontend using generated TypeScript proxies.

## Prerequisites

- .NET 10 SDK (the project targets `net10.0`)
- Docker with the Compose plugin (`docker compose`)
- Node.js `^20.19.0` or `>=22.12.0`
- The package manager you chose when scaffolding (yarn, pnpm, or npm)

## Getting started

1. Start the infrastructure:

   ```bash
   docker compose up -d
   ```

   This starts the Chronicle development image, with MongoDB bundled, on port 35000 (MongoDB on 27017), and an Aspire dashboard on `http://localhost:18888`. Chronicle is ready when `curl --insecure https://localhost:35000/health` prints `Healthy`.

2. Install the frontend dependencies, if the scaffold did not already do it:

   ```bash
   PACKAGE_MGR_INSTALL
   ```

3. Run the backend:

   ```bash
   dotnet run
   ```

4. In a second terminal, start the frontend development server:

   ```bash
   PACKAGE_MGR_DEV
   ```

Vite opens `http://localhost:9000` in your browser and forwards `/api`, `/.cratis`, and `/swagger` to the backend. Open **Demo**, select **Register**, and enter a name: the backend logs `Registered: <name>` and the name appears in the list.

| What | Where |
| --- | --- |
| Frontend (Vite dev server) | `http://localhost:9000` |
| Backend API | `http://localhost:5000` |
| Swagger UI | `http://localhost:5000/swagger` |
| Chronicle Workbench | `https://localhost:35000` (self-signed development certificate) |
| Aspire dashboard | `http://localhost:18888` |

The Workbench uses the development account described in the [Chronicle Workbench development guide](https://www.cratis.io/chronicle/workbench/development/).

To stop, press Ctrl+C in both terminals and run `docker compose down`. With MongoDB, the events and read models live inside the Chronicle container and are removed with it; use `docker compose stop` to keep them.

> [!CAUTION]
> The compose file publishes its ports on every network interface, and Chronicle runs with well-known development credentials. Use it only on a trusted machine, or prefix each port mapping with `127.0.0.1:` to keep it local.

### Yarn 2 and later

If you use Yarn 2 or later, it installs with Plug'n'Play by default, and the frontend build then fails with `Cannot find module` errors. Add a `.yarnrc.yml` containing `nodeLinker: node-modules` and run `yarn install` again, or use npm or pnpm.

## Choosing a database

MongoDB is the default. To use another database, pass `--Database` when you create the project:

```bash
dotnet new cratis --Database PostgreSQL
dotnet new cratis --Database MsSql
dotnet new cratis --Database SQLite
```

The choice determines:

- Which Arc read-model package the project uses: `Cratis.Arc.MongoDB` for MongoDB, `Cratis.Arc.EntityFrameworkCore` for the others, with the connection string in `ConnectionStrings:Cratis`.
- How the Chronicle container in `docker-compose.yml` stores its data: its embedded MongoDB, a PostgreSQL or SQL Server container, or an SQLite file on a named volume.

> [!WARNING]
> In the PostgreSQL variant, `ConnectionStrings:Cratis` signs in as `cratis`, but the PostgreSQL container only creates the `chronicle` role, so read-model queries fail with `28P01: password authentication failed`. The MsSql variant has not been verified end to end.

## AI assistance

This project ships with a `.cratis/ai.json` that selects its Cratis AI profiles, languages, and coding-agent harnesses.

1. Make sure the Cratis CLI is installed; see [https://cratis.io/cli](https://cratis.io/cli).
2. Run:

   ```bash
   cratis ai update
   ```

This installs the Cratis-managed AI rules, skills, and harness integration for the selected coding agents, such as `AGENTS.md` and the `.claude/`, `.cursor/`, `.github/`, `.opencode/`, and `.pi/` folders, and records everything it installed in `.cratis/ai.manifest.json`. Commit the installed content with your project. If you scaffolded with `cratis new`, this step has already run.

Run `cratis ai update` again whenever you want the latest guidance; it only touches Cratis-managed files, never yours. `cratis ai status` shows what is installed and whether a newer revision is available.

## Project structure

```shell
CratisApp.csproj          - .NET project file, including proxy generation settings
Program.cs                - Application entry point
GlobalUsings.cs           - Global using directives
CratisAppDbContext.cs     - Entity Framework Core context for the SQL database choices
appsettings.json          - Chronicle, database, and route configuration
package.json              - Frontend dependencies and scripts
tsconfig.json             - TypeScript configuration
eslint.config.mjs         - Lint configuration
docker-compose.yml        - Local Chronicle and Aspire dashboard
App.tsx, Home.tsx         - Root React component and home page
.frontend/                - Frontend shell
  index.html              - HTML entry point
  main.tsx                - React entry point
  index.css               - Global styles
  vite.config.ts          - Vite configuration, dev server port and proxies
<Module>/                 - A domain module
  <Feature>/              - A feature
    <Feature>.tsx         - React composition page
    index.ts              - TypeScript barrel export
    <Slice>/              - A vertical slice: C# and TypeScript side by side
      ...
```

## Vertical slices

Backend and frontend code for a behavior live side by side in the same folder. `SomeModule/SomeFeature/Registration/` holds the `Register` command, the `Registered` event, and a reactor in `Registration.cs`, the generated `Registration.ts` proxy, and the `RegisterDialog.tsx` component. You work on a feature in one place instead of across `Controllers/`, `Services/`, and `Components/`.

Run `dotnet build` after backend changes to regenerate the TypeScript proxies the frontend uses.

## TypeScript proxy generation

The `Cratis` package brings in `Cratis.Arc.ProxyGenerator.Build`, which regenerates the TypeScript proxies for your commands and queries on every `dotnet build`. The project file configures it like this:

```xml
<CratisProxiesOutputPath>$(MSBuildThisFileDirectory)</CratisProxiesOutputPath>
<CratisProxiesSegmentsToSkip>1</CratisProxiesSegmentsToSkip>
<CratisProxiesSkipOutputDeletion>true</CratisProxiesSkipOutputDeletion>
<CratisProxiesSkipCommandNameInRoute>true</CratisProxiesSkipCommandNameInRoute>
<CratisProxiesUseSourceFileAsOutputFile>true</CratisProxiesUseSourceFileAsOutputFile>
```

Each proxy is written next to the C# file that declares it, so `Registration.cs` produces `Registration.ts`.

Arc maps the backend routes from `Cratis:Arc:GeneratedApis` in `appsettings.json`, and the proxies must call the same routes. Keep these pairs in step:

| `appsettings.json` | `.csproj` | This project |
| --- | --- | --- |
| `RoutePrefix` | `CratisProxiesApiPrefix` | `api` for both (the defaults) |
| `SegmentsToSkipForRoute` | `CratisProxiesSegmentsToSkip` | `1` for both |
| `IncludeCommandNameInRoute` | `CratisProxiesSkipCommandNameInRoute` (inverted) | `false` / `true` |
| `IncludeQueryNameInRoute` | `CratisProxiesSkipQueryNameInRoute` (inverted) | defaults: `true` / `false` |

With these settings the `Register` command in `CratisApp.SomeModule.SomeFeature.Registration` is served at `/api/some-module/some-feature/registration`. If the pairs drift apart, the generated proxies call routes the backend does not map.

## Learn more

- [Cratis Arc documentation](https://www.cratis.io/arc/)
- [Arc ASP.NET Core configuration](https://www.cratis.io/arc/backend/csharp/asp-net-core/configuration/)
- [Arc proxy generator configuration](https://www.cratis.io/arc/backend/csharp/proxy-generation/configuration/)
- [Arc model-bound commands](https://www.cratis.io/arc/backend/csharp/commands/model-bound/)
- [Arc model-bound queries](https://www.cratis.io/arc/backend/csharp/queries/model-bound/)
- [Chronicle documentation](https://www.cratis.io/chronicle/)
- [Cratis templates documentation](https://www.cratis.io/templates/)
