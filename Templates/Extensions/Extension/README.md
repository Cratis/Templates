# TEXT_DISPLAY_NAME

TEXT_DESCRIPTION

`ExtensionName` is a [Cratis extension](https://github.com/Cratis/Screenplay/blob/main/Documentation/screenplay/extension-contracts.md): one package that a Screenplay model references to reach something outside it. [`contract.play`](contract.play) is its manifest and its contract: the display name, description, icon, marketplace images, what it requires and everything it contributes.

This package was created with `cratis extension new` (or `dotnet new cratis-extension`) with these choices:

| Choice | Value |
| --- | --- |
| Backend | `BACKEND_KIND` |
| Frontend | `FRONTEND_KIND` |
| Publisher | `PUBLISHER` |

## What is in the folder

| Path | What it is | Shipped |
| --- | --- | --- |
| `contract.play` | The manifest and the contract: abilities, settings, components, backend and frontend. | yes |
| `assets/` | The icon and the marketplace image. Both are placeholders: replace them with your own. | yes |
<!--#if (Frontend == "react" || Frontend == "mount") -->
| `placeholders/` | A static HTML placeholder per component, which design tools such as Studio draw instead of the component. No script, no event handlers, no external files. | yes |
| `frontend/` | The built frontend, `frontend/index.js`, written by `scripts/build.sh`. | yes |
| `src/frontend-FRONTEND_KIND/` | The component source and its specifications. | no |
<!--#endif -->
<!--#if (Frontend == "screenplay") -->
| `ui/` | The component, authored as a Screenplay template. | yes |
<!--#endif -->
<!--#if (Backend != "none") -->
| `backend/` | The built backend, written by `scripts/build.sh`. | yes |
| `src/backend-BACKEND_KIND/` | The backend source and its specifications. | no |
<!--#endif -->
| `scripts/` | Build, test, package, verify and publish scripts. | no |
| `Dockerfile` | Puts the package at `/extension` in an OCI image. | no |
| `.extensionignore` | Names what the folder holds that the package does not ship. | no |

`cratis extension verify` holds the folder to this table: everything it ships must be declared by `contract.play`, and everything else must be named in `.extensionignore`. When you add a file the package ships, declare it in the contract; when you add one it does not ship, list it in `.extensionignore`.

## The sample

`contract.play` declares one ability, `Greet`, that takes a `name` and returns a `message`, and a public setting, `greeting`.
<!--#if (Backend != "none") -->
The backend realizes the ability and reads the setting through the host services.
<!--#else -->
The extension has no backend, so nothing realizes the ability yet: add one with `cratis extension new --backend`, or declare only what a model needs from this package.
<!--#endif -->
<!--#if (Frontend == "react" || Frontend == "mount") -->
The `ExtensionNamePanel` component takes a `label`, calls `Greet` through the host and raises `greeted` with the message.
<!--#endif -->
<!--#if (Frontend == "screenplay") -->
The `ExtensionNamePanel` component is declared by `contract.play` and drawn by the Screenplay template in `ui/`.
<!--#endif -->

Change the sample into what your extension does, and keep the contract and the code in step: Stage checks what the backend declares against `contract.play` when it connects.

## Build, test and verify

```bash
scripts/test.sh      # run the specifications
scripts/build.sh     # build the backend and the frontend into backend/ and frontend/
scripts/package.sh   # lay the package out in dist/extension
scripts/verify.sh    # cratis extension verify .
```

`scripts/publish.sh <version>` builds, packages and pushes the package as an OCI image to `ghcr.io/PUBLISHER/extension-EXTENSION_KEBAB`. Sign it as the Stage's trust policy requires.
<!--#if (Backend == "kotlin" || Backend == "go" || Backend == "typescript" || Frontend == "react" || Frontend == "mount") -->

### Until the SDKs are published

The Kotlin, Go and TypeScript backend SDKs and `@cratis/scene.extensions` are not on their registries yet. Until they are, point the scripts at a local build:

| Variable | Points at |
| --- | --- |
| `CRATIS_STAGE_SDK` | A clone of [Cratis/Stage](https://github.com/Cratis/Stage). For a TypeScript backend run `npm install && npm run build` in `Source/Extensions/TypeScript` first. |
| `CRATIS_SCENE_SDK` | The `@cratis/scene.extensions` package as a tarball: run `npm pack` in `Source/JavaScript/extensions` of a clone of [Cratis/Scene](https://github.com/Cratis/Scene). |

The scripts edit the dependency in `package.json` or `go.mod` to use the local build. Do not commit that edit.
<!--#endif -->

## Run the backend

<!--#if (Backend == "none") -->
There is no backend to run.
<!--#else -->
Stage starts the backend itself and tells it where to listen with `STAGE_EXTENSION_LISTEN`. To run it by hand, build it and start it from `backend/`, then point Stage at it as [connect a backend](https://github.com/Cratis/Stage/blob/main/Documentation/extensions/connect-a-backend.md) describes.
<!--#endif -->

## Learn more

- [Extension contracts](https://github.com/Cratis/Screenplay/blob/main/Documentation/screenplay/extension-contracts.md): `contract.play` and the manifest.
- [Extensions in Stage](https://github.com/Cratis/Stage/blob/main/Documentation/extensions/index.md): the protocol, the host services, the backend SDKs and how packages load.
- [The extension component contract](https://github.com/Cratis/Scene/blob/main/Documentation/extensions/contract.md): the React and mount component kinds and the conformance kit.
- [`cratis extension new`](https://github.com/Cratis/cli/blob/main/Documentation/reference/extension-new.md) and [`cratis extension verify`](https://github.com/Cratis/cli/blob/main/Documentation/reference/extension-verify.md).
- [The extension templates](https://github.com/Cratis/Templates/blob/main/Documentation/extensions/index.mdx).
