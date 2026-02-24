# CratisApp

A web application built with Cratis Arc and Chronicle.

## Prerequisites

- .NET 9.0 or later
- Docker and Docker Compose (for running Chronicle and Aspire Dashboard)
//#if (EnableFrontend)
- Node.js 20 or later
- Yarn
//#endif

## Getting Started

1. Start the infrastructure:

```bash
docker-compose up -d
```

This will start:
- Chronicle (with MongoDB on port 27017)
- Aspire Dashboard (on port 18888)

//#if (EnableFrontend)
2. Install frontend dependencies:

```bash
yarn install
```

3. Start the frontend development server:

```bash
yarn dev
```

4. Run the application:

```bash
dotnet run
```

The application will be available at:
- Backend API: http://localhost:5000
- Swagger UI: http://localhost:5000/swagger
- Frontend: http://localhost:5173 (Vite dev server)
- Aspire Dashboard: http://localhost:18888

//#else
2. Run the application:

```bash
dotnet run
```

The application will be available at:
- API: http://localhost:5000
- Swagger UI: http://localhost:5000/swagger
- Aspire Dashboard: http://localhost:18888
//#endif

## Project Structure

- `Source/` - All source code (backend and frontend side by side)
  - `Program.cs` - Application entry point
  - `appsettings.json` - Configuration
  - `CratisApp.csproj` - .NET project file
  //#if (EnableFrontend)
  - `index.html` - Frontend entry point
  - `App.tsx`, `main.tsx` - Frontend components
  - `App.css`, `index.css` - Styles
  - `package.json` - Node.js dependencies
  - `vite.config.ts` - Vite configuration
  - `tsconfig.json` - TypeScript configuration
  //#endif
- `docker-compose.yml` - Infrastructure services
- `wwwroot/` - Built frontend files (generated)

## Cratis Build Tool (Proxy Generation)

This template is designed to work with `Cratis.Arc.ProxyGenerator.Build`, which generates TypeScript command/query proxies during `dotnet build`.

### Add package reference

If not already present, add the build package to your `.csproj`:

```xml
<ItemGroup>
  <PackageReference Include="Cratis.Arc.ProxyGenerator.Build" Version="<version>" />
</ItemGroup>
```

### Required setting

`CratisProxiesOutputPath` tells the build tool where generated TypeScript proxies should be written.

```xml
<PropertyGroup>
  <CratisProxiesOutputPath>$(MSBuildThisFileDirectory)Features</CratisProxiesOutputPath>
</PropertyGroup>
```

### Common configuration

```xml
<PropertyGroup>
  <CratisProxiesOutputPath>$(MSBuildThisFileDirectory)Features</CratisProxiesOutputPath>
  <CratisProxiesSegmentsToSkip>1</CratisProxiesSegmentsToSkip>
  <CratisProxiesSkipOutputDeletion>true</CratisProxiesSkipOutputDeletion>
  <CratisProxiesSkipCommandNameInRoute>true</CratisProxiesSkipCommandNameInRoute>
  <CratisProxiesSkipQueryNameInRoute>false</CratisProxiesSkipQueryNameInRoute>
  <CratisProxiesApiPrefix>api</CratisProxiesApiPrefix>
  <CratisProxiesSkipFileIndexTracking>false</CratisProxiesSkipFileIndexTracking>
  <CratisProxiesSkipIndexGeneration>false</CratisProxiesSkipIndexGeneration>
</PropertyGroup>
```

### What each setting does

- `CratisProxiesOutputPath`: Output directory for generated proxies.
- `CratisProxiesSegmentsToSkip`: Skips namespace segments when creating folder paths.
- `CratisProxiesSkipOutputDeletion`: When `false` (default), output folder is deleted on each build; set `true` for incremental generation.
- `CratisProxiesSkipCommandNameInRoute`: Excludes command names from generated routes when possible.
- `CratisProxiesSkipQueryNameInRoute`: Excludes query names from generated routes when possible.
- `CratisProxiesApiPrefix`: API prefix used in generated routes (default `api`).
- `CratisProxiesSkipFileIndexTracking`: Disables orphan-file tracking when `true`.
- `CratisProxiesSkipIndexGeneration`: Disables `index.ts` generation when `true`.

### Verify generation

Run:

```bash
dotnet build
```

Then inspect your configured `CratisProxiesOutputPath` directory for generated proxies.

## Learn More

- [Cratis Arc Documentation](https://www.cratis.io/docs/Arc/)
- [Cratis Arc Proxy Generation Configuration](https://www.cratis.io/docs/Arc/backend/proxy-generation/index.html)
- [Chronicle Documentation](https://www.cratis.io/docs/Chronicle/)
