# Cratis Templates

This repository contains all creation templates used by Cratis. It holds project and item templates you can use to scaffold new Cratis-based applications, components, and sample projects.

## Build & Test Locally

Prerequisites:

- .NET SDK (recommended 8.0+)
- Node.js and npm (if testing frontend/Vite templates)

### Pack and install the templates locally

```bash
dotnet pack Cratis.Templates.csproj -c Release -o ./nupkgs
dotnet new -i ./nupkgs
```

If you prefer to install directly from the template folder (unpacked):

```bash
dotnet new -i ./Cratis.Templates
```

### List available templates and find the short name

```bash
dotnet new --list
```

### Create a test project from a template (replace <shortname> with the template short name)

```bash
dotnet new <shortname> -n MyTestApp
cd MyTestApp
dotnet restore
dotnet build
dotnet run
```

### If the generated project includes a frontend (Vite/Node)

```bash
cd path/to/generated/frontend
npm install
npm run dev
```

### Uninstall the local template when finished

```bash
dotnet new -u <package-id-or-folder>
```

Iterate on the template sources, repack, and reinstall to test changes quickly.
