// Points a dependency of a package.json at a local build: node link-sdk.mjs <folder> <package> <path>
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const [folder, name, path] = process.argv.slice(2);
const file = `${folder}/package.json`;
const json = JSON.parse(readFileSync(file, 'utf8'));
for (const section of ['dependencies', 'devDependencies']) {
    if (json[section]?.[name]) {
        json[section][name] = `file:${resolve(path)}`;
    }
}
writeFileSync(file, `${JSON.stringify(json, null, 4)}\n`);
