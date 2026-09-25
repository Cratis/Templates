# ChronicleConsole

Scaffolded console application for building with Cratis Chronicle.

## Prerequisites

- .NET 10 SDK (the project targets `net10.0`)
- Docker with the Compose plugin (`docker compose`)

## Getting Started

1. Start Chronicle and the Aspire dashboard:

   ```bash
   docker compose up -d
   ```

2. Run the console app from an interactive terminal:

   ```bash
   dotnet run
   ```

   The app appends a `TestEvent`, the reactor prints `Received event with message: Hello world!`, and the app waits for a key press. Press any key to exit. Each run appends another event to the `some-event-source` event source.

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
  - Application entry point.
  - Creates a Chronicle client that connects to the local development kernel (`chronicle://localhost:35000`) and gets an event store named `ChronicleConsole`.
  - Appends a sample event to demonstrate writing events, then waits for a key press.
  - Contains:
    - `TestEvent`: example event type.
    - `TestProjection`: example model-bound projection.
    - `TestReactor`: example reactor that handles the event.

- `ChronicleConsole.csproj`
  - Project file for the console app.
  - Defines output type, target framework, nullable and implicit usings, and the `Cratis.Chronicle` package reference.

- `ChronicleConsole.sln`
  - Solution file for opening/building in IDEs.

- `docker-compose.yml`
  - Starts local infrastructure:
    - Chronicle (gRPC, API, and Workbench on port 35000)
    - Aspire dashboard (`http://localhost:18888`)

## Next Steps

- Replace the sample `TestEvent`, `TestProjection`, and `TestReactor` with your domain concepts.
- Add your own event flows and read-model queries.
- Expand from console workflow into API or web experiences as needed.

For more guidance on building Cratis applications, see:

- [Cratis](https://www.cratis.io)
- [Chronicle documentation](https://www.cratis.io/chronicle/)
- [Cratis templates documentation](https://www.cratis.io/templates/)
