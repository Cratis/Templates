# ChronicleWeb

Scaffolded ASP.NET Core web application built with Cratis Chronicle.

## Prerequisites

- .NET 10 SDK (the project targets `net10.0`)
- Docker with the Compose plugin (`docker compose`)

## Getting Started

1. Start Chronicle and the Aspire dashboard:

   ```bash
   docker compose up -d
   ```

2. Run the web app:

   ```bash
   dotnet run
   ```

   It listens on `http://localhost:5000`.

3. Call the sample endpoints:

   ```bash
   curl http://localhost:5000/           # appends a TestEvent
   curl http://localhost:5000/projection # returns the projected read models
   ```

   The first call returns the append result with `"isSuccess":true`, and the app logs `Received event with message: Hello, Chronicle!` from the reactor. The second returns the projected instances, such as `[{"message":"Hello, Chronicle!","eventSource":"..."}]`.

To stop Chronicle, run `docker compose down`. With the default MongoDB setup the events live inside the Chronicle container and are removed with it; `docker compose stop` keeps them.

> [!CAUTION]
> The compose file publishes its ports on every network interface, and Chronicle runs with well-known development credentials. Use it only on a trusted machine, or prefix each port mapping with `127.0.0.1:` to keep it local.

## AI assistance

This project ships with a `.cratis/ai.json` that selects its Cratis AI profiles, languages, and coding-agent harnesses.

1. Make sure the Cratis CLI is installed; see [https://cratis.io/cli](https://cratis.io/cli).
2. Run:

   ```bash
   cratis ai update
   ```

This installs the Cratis-managed AI rules, skills, and harness integration for the selected coding agents, such as `AGENTS.md` and the `.claude/`, `.cursor/`, `.github/`, `.opencode/`, and `.pi/` folders, and records everything it installed in `.cratis/ai.manifest.json`. Commit the installed content with your project. If you scaffolded with `cratis new`, this step has already run.

Re-run `cratis ai update` whenever you want the latest guidance; it only touches Cratis-managed files, never yours. `cratis ai status` shows what is installed and whether a newer revision is available.

## Artifacts

- `Program.cs`
  - Application entry point and web pipeline setup.
  - Configures Chronicle integration through `AddCratisChronicle()` and `UseCratisChronicle()`.
  - Exposes sample endpoints:
    - `GET /` appends a sample event. It uses `GET` only to keep the demo to one `curl`; use `POST` for your own state-changing endpoints.
    - `/projection` returns projection instances.
  - Contains:
    - `TestEvent`: example event type.
    - `TestProjection`: example model-bound projection.
    - `TestReactor`: example reactor.

- `ChronicleWeb.csproj`
  - ASP.NET Core project file with framework and compiler settings.

- `ChronicleWeb.sln`
  - Solution file for opening/building in IDEs.

- `appsettings.json`
  - Runtime configuration, including the Chronicle event store name and the development connection string.

- `appsettings.Development.json`
  - Development-time logging overrides.

- `docker-compose.yml`
  - Starts local infrastructure:
    - Chronicle (gRPC, API, and Workbench on port 35000)
    - Aspire dashboard (`http://localhost:18888`)

## Next Steps

- Replace sample events/projections/reactors with your domain model.
- Add APIs or UI endpoints around your read models.
- Introduce authentication, validation, and production configuration as needed.

For more guidance on building Cratis applications, see:

- [Cratis](https://www.cratis.io)
- [Chronicle documentation](https://www.cratis.io/chronicle/)
- [Cratis templates documentation](https://www.cratis.io/templates/)
