# ChronicleWeb

Scaffolded ASP.NET Core web application built with Cratis Chronicle.

## Prerequisites

- .NET SDK (matching the target framework used when the template is generated)
- Docker and Docker Compose

## Getting Started

1. Start Chronicle and the Aspire dashboard:

```bash
docker-compose up -d
```

2. Run the web app:

```bash
dotnet run
```

3. Open the app:

- Test event appending endpoint: http://localhost:5000/
- Test Projection endpoint: http://localhost:5000/projection

## Artifacts

- `Program.cs`
  - Application entry point and web pipeline setup.
  - Configures Chronicle integration through `AddCratisChronicle()` and `UseCratisChronicle()`.
  - Exposes sample endpoints:
    - `/` appends a sample event.
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
  - Runtime configuration, including Chronicle event store and connection string.

- `appsettings.Development.json`
  - Development-time logging overrides.

- `Properties/launchSettings.json`
  - Local run profile configuration (`dotnet run`/IDE launch settings).

- `docker-compose.yml`
  - Starts local infrastructure:
    - Chronicle
    - .NET Aspire dashboard

## Next Steps

- Replace sample events/projections/reactors with your domain model.
- Add APIs or UI endpoints around your read models.
- Introduce authentication, validation, and production configuration as needed.

For more guidance on building Cratis applications, see:

- https://cratis.io
- https://cratis.io/docs/Chronicle/index
