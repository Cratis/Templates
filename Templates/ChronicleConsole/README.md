# ChronicleConsole

Scaffolded console application for building with Cratis Chronicle.

## Prerequisites

- .NET SDK (matching the target framework used when the template is generated)
- Docker and Docker Compose

## Getting Started

1. Start Chronicle and the Aspire dashboard:

```bash
docker-compose up -d
```

2. Run the console app:

```bash
dotnet run
```

## Artifacts

- `Program.cs`
  - Application entry point.
  - Creates a Chronicle client and gets an event store named `ChronicleConsole`.
  - Appends a sample event to demonstrate writing events.
  - Contains:
    - `TestEvent`: example event type.
    - `TestProjection`: example model-bound projection.
    - `TestReactor`: example reactor that handles the event.

- `ChronicleConsole.csproj`
  - Project file for the console app.
  - Defines output type, target framework, namespace, nullable and implicit usings.

- `ChronicleConsole.sln`
  - Solution file for opening/building in IDEs.

- `docker-compose.yml`
  - Starts local infrastructure:
    - Chronicle
    - .NET Aspire dashboard

## Next Steps

- Replace the sample `TestEvent`, `TestProjection`, and `TestReactor` with your domain concepts.
- Add your own event flows and read-model queries.
- Expand from console workflow into API or web experiences as needed.

For more guidance on building Cratis applications, see:

- https://cratis.io
- https://cratis.io/docs/Chronicle/index
