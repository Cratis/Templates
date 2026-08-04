# Cratis Templates

[![Nuget](https://img.shields.io/nuget/v/Cratis.Templates?logo=nuget)](http://nuget.org/packages/Cratis.Templates)

This repository contains all creation templates used by Cratis. It holds project and item templates you can use to scaffold new Cratis-based applications, components, and sample projects.

## Builds

[![Publish](https://github.com/Cratis/Templates/actions/workflows/publish.yml/badge.svg)](https://github.com/Cratis/Templates/actions/workflows/publish.yml)

## How to use

Quick steps to scaffold projects from these templates:

- Install the published templates from NuGet.org (one-time):

```bash
dotnet new install Cratis.Templates
```

- Optional: install a specific version:

```bash
dotnet new install Cratis.Templates::<version>
```

- Optional: install prerelease builds from GitHub Packages:

```bash
dotnet nuget add source --name cratis-github --username <github-username> --password <github-token> --store-password-in-clear-text https://nuget.pkg.github.com/cratis/index.json
dotnet new install Cratis.Templates::<version> --nuget-source https://nuget.pkg.github.com/cratis/index.json
```

- List available templates and note the `Short Name` you want:

```bash
dotnet new --list
```

- Create a new project from a template (replace `<shortname>`):

```bash
dotnet new <shortname> -n MyApp -o MyApp
```

- Many templates accept parameters; run `dotnet new <shortname> --help` to see available options.

- Uninstall when needed:

```bash
dotnet new uninstall Cratis.Templates
```

### Updating installed templates

To update to the latest version:

```bash
dotnet new update
```

This updates all installed template packages to their latest versions.

To update only Cratis.Templates:

```bash
dotnet new uninstall Cratis.Templates
dotnet new install Cratis.Templates
```

To check which version you currently have installed:

```bash
dotnet new list
```

Look for `Cratis.Templates` in the output to see the installed version.

To update to a specific version:

```bash
dotnet new uninstall Cratis.Templates
dotnet new install Cratis.Templates::<version>
```


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

### Verify the emitted frontend asset layout

```bash
./verify-asset-layout.sh
```

Scaffolds both Vite-based templates, builds their frontends, and checks that every
hashed build artifact lands under `wwwroot/assets/` rather than at the `wwwroot`
root. A flat root layout cannot be expressed as a reverse-proxy, CDN or WAF path
rule — the artifacts are hash-named, change every build and share no prefix — so
the failure only shows up at deployment, as a blank page. CI runs the same script
against the applications it has already generated.

Pass application directories to check ones you have already scaffolded:

```bash
./verify-asset-layout.sh path/to/MyTestApp
```

### Uninstall the local template when finished

```bash
dotnet new -u <package-id-or-folder>
```

Iterate on the template sources, repack, and reinstall to test changes quickly.