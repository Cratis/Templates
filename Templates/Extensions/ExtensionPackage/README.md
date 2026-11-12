# TEXT_DISPLAY_NAME

TEXT_DESCRIPTION

`@PUBLISHER/EXTENSION_KEBAB` is a frontend-only [Cratis extension](https://github.com/Cratis/Screenplay/blob/main/Documentation/screenplay/extension-contracts.md) published to npm. It has no backend, so it needs no process. [`contract.play`](contract.play) is its manifest and its contract: the display name, description, icon, marketplace images, what it requires and the components it contributes. A Screenplay model references it as `extension "npm:@PUBLISHER/EXTENSION_KEBAB"`.

It was created with `cratis extension new --kind package` (or `dotnet new cratis-extension-package`) for a `COMPONENT_KIND` component.

## What is in the folder

| Path | What it is | Published |
| --- | --- | --- |
| `contract.play` | The manifest and the contract. | yes |
| `assets/` | The icon and the marketplace image. Both are placeholders: replace them with your own. | yes |
| `placeholders/` | A static HTML placeholder for each component, which design tools such as Studio draw instead of the component. No script, no event handlers, no external files. | yes |
| `dist/` | The built frontend, `dist/index.js`, written by `npm run build`. | yes |
| `src/`, `test/` | The component source and its specifications. | no |
| `package.json` | Lists what npm publishes in `files`. | no |
| `.extensionignore` | Names what the folder holds that the package does not publish. | no |

`cratis extension verify` holds the folder to this table: everything the package publishes must be declared by `contract.play`, and everything else must be named in `.extensionignore`. When you add a file the package publishes, declare it in the contract and list it in `files`; when you add one it does not publish, list it in `.extensionignore`.

## The sample

The `ExtensionNamePanel` component takes a `label`, shows it with the user's name and language, and raises `greeted` when the user presses the button. It is a `COMPONENT_KIND` component: the built module exports it by the name `contract.play` declares, and the host mounts it with the same context whatever its kind.

Change the sample into what your package does, and keep the contract and the code in step.

## Build, test and verify

```bash
npm install
npm test             # the specifications, including the Scene conformance kit
npm run build        # build dist/index.js
npm run verify       # cratis extension verify .
```

`npm publish` builds the package (`prepack`) and publishes `contract.play`, `assets/`, `placeholders/` and `dist/`.

### Until the component contract is published

`@cratis/scene.extensions` is not on npm yet. Until it is, build the tarball from a clone of [Cratis/Scene](https://github.com/Cratis/Scene) (`npm pack` in `Source/JavaScript/extensions`) and install it in place of the dependency:

```bash
npm install --save-dev ../path/to/cratis-scene.extensions-1.0.0.tgz
```

Do not commit that change to `package.json`.

## Learn more

- [Extension contracts](https://github.com/Cratis/Screenplay/blob/main/Documentation/screenplay/extension-contracts.md): `contract.play` and the manifest.
- [The extension component contract](https://github.com/Cratis/Scene/blob/main/Documentation/extensions/contract.md): the React and mount component kinds, the context and the conformance kit.
- [Build an extension component](https://github.com/Cratis/Scene/blob/main/Documentation/extensions/build-a-component.md).
- [Extensions in Stage](https://github.com/Cratis/Stage/blob/main/Documentation/extensions/index.md): how packages load.
- [`cratis extension new`](https://github.com/Cratis/cli/blob/main/Documentation/reference/extension-new.md) and [`cratis extension verify`](https://github.com/Cratis/cli/blob/main/Documentation/reference/extension-verify.md).
- [The extension templates](https://github.com/Cratis/Templates/blob/main/Documentation/extensions/index.mdx).
