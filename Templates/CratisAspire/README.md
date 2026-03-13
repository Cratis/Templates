# CratisAspire

A web application built with Cratis Arc, Chronicle, and .NET Aspire orchestration.

## Prerequisites

- .NET 9.0 or later
- Node.js 20 or later
- Yarn

## Getting Started

1. Install frontend dependencies:

```bash
cd CratisAspire
yarn install
```

2. Run the application via the Aspire Composition host:

```bash
dotnet run --project CratisAspire.Composition
```

Aspire will automatically start and configure:

- Chronicle (event store + MongoDB)
- The backend application
- The Aspire Dashboard for observability

3. Start the frontend development server (optional, for hot-reload during development):

```bash
cd CratisAspire
yarn dev
```

The application will be available at:

- Backend API: http://localhost:5000
- Swagger UI: http://localhost:5000/swagger
- Frontend: http://localhost:9000 (Vite dev server) or served from the backend
- Aspire Dashboard: http://localhost:15888

## Project Structure

```shell
CratisAspire.sln                          - Solution file
CratisAspire/                             - Main web application
  CratisAspire.csproj                     - .NET project file
  Program.cs                              - Application entry point
  GlobalUsings.cs                         - Global using directives
  appsettings.json                        - Configuration
  package.json                            - Node.js dependencies
  tsconfig.json                           - TypeScript configuration
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
  Extensions.cs                           - OpenTelemetry, health checks, service discovery
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
- **Health checks** — `/health` and `/alive` endpoints
- **Service discovery** — automatic service resolution via Aspire
- **HTTP resilience** — retry policies and circuit breakers

## Vertical Slices

Each feature is organized as a vertical slice — all backend and frontend code for a behavior lives together:

```shell
SomeModule/
  SomeFeature/
    SomeName.cs               - Domain concept (strongly-typed value)
    SomeFeature.tsx           - React page component
    index.ts                  - Barrel export
    Registration/
      Registration.cs         - Command, Event, Reactor (all in one file)
      Register.ts             - Generated TypeScript proxy
      RegisterDialog.tsx      - React dialog component
      index.ts                - Barrel export
    Listing/
      Listing.cs              - Read model + projection + query
      Listing.ts              - Generated TypeScript proxy
      AllListings.ts          - Generated observable query proxy
      ListingDataTable.tsx    - React data table component
      index.ts                - Barrel export
```

## Cratis Build Tool (Proxy Generation)

This template is designed to work with `Cratis.Arc.ProxyGenerator.Build`, which generates TypeScript command/query proxies during `dotnet build`.

### Add package reference

```bash
dotnet add CratisAspire package Cratis.Arc.ProxyGenerator.Build
```

### Common configuration

```xml
<PropertyGroup>
  <CratisProxiesOutputPath>$(MSBuildThisFileDirectory)</CratisProxiesOutputPath>
  <CratisProxiesSegmentsToSkip>1</CratisProxiesSegmentsToSkip>
  <CratisProxiesSkipOutputDeletion>true</CratisProxiesSkipOutputDeletion>
  <CratisProxiesSkipCommandNameInRoute>true</CratisProxiesSkipCommandNameInRoute>
  <CratisProxiesSkipQueryNameInRoute>false</CratisProxiesSkipQueryNameInRoute>
  <CratisProxiesApiPrefix>api</CratisProxiesApiPrefix>
  <CratisProxiesSkipFileIndexTracking>false</CratisProxiesSkipFileIndexTracking>
  <CratisProxiesSkipIndexGeneration>false</CratisProxiesSkipIndexGeneration>
</PropertyGroup>
```

## Learn More

- [Cratis Arc Documentation](https://www.cratis.io/docs/Arc/)
- [Cratis Arc ASP.NET Core Configuration](https://www.cratis.io/docs/Arc/backend/asp-net-core/configuration.html)
- [Cratis Arc Proxy Generation Configuration](https://www.cratis.io/docs/Arc/backend/proxy-generation/index.html)
- [Cratis Arc Model Bound Commands](https://www.cratis.io/docs/Arc/backend/commands/model-bound/index.html)
- [Cratis Arc Model Bound Queries](https://www.cratis.io/docs/Arc/backend/queries/model-bound/index.html)
- [Chronicle Documentation](https://www.cratis.io/docs/Chronicle/)
- [.NET Aspire Documentation](https://learn.microsoft.com/en-us/dotnet/aspire/)
