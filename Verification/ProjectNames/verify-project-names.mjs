// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import process from 'node:process';

const [option, name, ...applications] = process.argv.slice(2);
if (option !== '--name' || !name || applications.length === 0) {
    console.error('Usage: node verify-project-names.mjs --name <projectName> <kind>=<dir> [...]');
    process.exit(1);
}
const store = name.replace(/[\/\\. "$*<>:|?]/g, '');
const id = name.replace(/(((?<=\.)|^)(?=\d)|\W)/g, '_');
const segments = name.split('.').length;
let checked = 0;
let failed = 0;

function check(file, condition, message) {
    checked++;
    if (!condition) {
        failed++;
        console.error(`::error::${file}: ${message}`);
    }
}

function read(file) {
    check(file, existsSync(file), 'file must exist');
    return existsSync(file) ? readFileSync(file, 'utf8') : '';
}

function contains(file, text) {
    check(file, read(file).includes(text), `must contain ${text}`);
}

function files(root) {
    if (!existsSync(root)) return [];
    return readdirSync(root, { withFileTypes: true }).flatMap(entry => {
        if (['node_modules', 'bin', 'obj', 'wwwroot', '.git'].includes(entry.name)) return [];
        const path = join(root, entry.name);
        return entry.isDirectory() ? files(path) : [path];
    });
}

function paths(root, requireRegister = false) {
    const file = join(root, '.frontend/tsconfig.json');
    const text = read(file);
    const match = text.match(/"paths"\s*:\s*(\{[\s\S]*?\})/);
    if (!match) return;
    const aliases = JSON.parse(match[1].replace(/\/\*[\s\S]*?\*\//g, '').replace(/,\s*([}\]])/g, '$1'));
    for (const targets of Object.values(aliases)) {
        for (const target of targets) {
            const path = resolve(dirname(file), target.replace(/\/\*$/, ''));
            check(file, existsSync(path), `paths target must exist: ${target}`);
            if (requireRegister) check(path, existsSync(join(path, 'Register.ts')), 'must contain Register.ts');
        }
    }
}

function web(root, connectionFile = join(root, 'appsettings.json')) {
    const settingsFile = join(root, 'appsettings.json');
    const settings = JSON.parse(read(settingsFile));
    check(settingsFile, settings.Cratis?.Chronicle?.EventStore === store, `EventStore must be ${store}`);
    check(settingsFile, settings.Cratis?.Arc?.GeneratedApis?.SegmentsToSkipForRoute === segments, `SegmentsToSkipForRoute must be ${segments}`);
    const sql = settings.Cratis?.Chronicle?.DefaultSinkTypeId === 'SQL';
    if (sql) {
        contains(connectionFile, `chronicle+${store}`);
        const context = join(root, `${id}DbContext.cs`);
        contains(context, `class ${id}DbContext`);
    } else {
        check(settingsFile, settings.Cratis?.MongoDB?.Database === store, `Database must be ${store}`);
    }
    contains(join(root, `${name}.csproj`), `<CratisProxiesSegmentsToSkip>${segments}<`);
    const vite = join(root, '.frontend/vite.config.ts');
    check(vite, !read(vite).includes("'Api'"), 'must not have an Api alias');
    const tsconfig = join(root, '.frontend/tsconfig.json');
    check(tsconfig, !read(tsconfig).includes('"Api/*"'), 'must not have an Api/* alias');
    paths(root);
    const allFiles = files(root);
    for (const proxy of ['Registration', 'Listing']) {
        const expected = join(root, 'SomeModule/SomeFeature', proxy, `${proxy}.ts`);
        const matches = allFiles.filter(file => file.endsWith(`/${proxy}.ts`));
        check(expected, matches.length === 1 && matches[0] === expected, `must be the only ${proxy}.ts`);
    }
    contains(join(root, 'SomeModule/SomeFeature/Registration/Registration.ts'), "'/api/some-module/some-feature/registration'");
    if (name !== store) {
        for (const file of allFiles) {
            check(file, !readFileSync(file).includes(`chronicle+${name}`), `must not contain chronicle+${name}`);
        }
    }
    return sql;
}

function jvm(root, built) {
    contains(join(root, 'src/main/resources/application.properties'), `cratis.chronicle.event-store=${store}`);
    contains(join(root, 'build.gradle.kts'), `moduleName = "${id}"`);
    const java = join(root, `src/main/java/com/example/${id}Application.java`);
    const kotlin = join(root, `src/main/kotlin/com/example/${id}Application.kt`);
    check(root, existsSync(java) || existsSync(kotlin), `must have ${id}Application.java or .kt`);
    if (built) paths(root, true);
}

for (const application of applications) {
    const separator = application.indexOf('=');
    const kind = application.slice(0, separator);
    const root = resolve(application.slice(separator + 1));
    try {
        switch (kind) {
            case 'web': web(root); break;
            case 'aspire': {
                const program = join(root, `${name}.Composition/Program.cs`);
                web(join(root, name), program);
                contains(program, `Projects.${id}>`);
                break;
            }
            case 'console': contains(join(root, 'Program.cs'), `GetEventStore("${store}")`); break;
            case 'chronicle-web': contains(join(root, 'appsettings.json'), `"EventStore": "${store}"`); break;
            case 'jvm': jvm(root, true); break;
            case 'jvm-scaffold': jvm(root, false); break;
            default: check(application, false, `unknown kind: ${kind}`);
        }
    } catch (error) {
        check(root, false, error.message);
    }
}
console.log(`Checked ${checked} project-name expectations; ${failed} failed`);
process.exitCode = failed > 0 ? 1 : 0;
