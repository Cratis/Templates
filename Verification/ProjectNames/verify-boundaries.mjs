// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const [output, cli] = process.argv.slice(2);
if (!output || existsSync(output) || (cli && cli !== '--cli')) {
    console.error('Usage: node verify-boundaries.mjs <new-output-directory> [--cli]');
    process.exit(1);
}
const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
const workspace = resolve(output);
mkdirSync(workspace, { recursive: true });
const hive = ['--debug:custom-hive', join(workspace, 'hive')];

function run(command, args) {
    console.log(`$ ${command} ${args.join(' ')}`);
    const result = spawnSync(command, args, { cwd: root, encoding: 'utf8' });
    if (result.stdout) console.log(result.stdout.trim());
    if (result.stderr) console.error(result.stderr.trim());
    if (result.error) throw result.error;
    assert.equal(result.status, 0, `${command} must succeed`);
    return result.stdout.trim();
}

function verify(application, kind, name, count) {
    run(process.execPath, [join(root, 'Verification/ProjectNames/verify-project-names.mjs'), '--name', name, `${kind}=${application}`]);
    const projectRoot = kind === 'aspire' ? join(application, name) : application;
    const evaluated = run('dotnet', ['msbuild', join(projectRoot, `${name}.csproj`), '-getProperty:CratisProxiesSegmentsToSkip', '-verbosity:quiet']);
    assert.equal(evaluated, String(count), `${kind}: MSBuild must count ${count} namespace segments`);
    assert.equal(existsSync(join(projectRoot, 'obj')), false, 'must not restore');
    assert.equal(existsSync(join(projectRoot, 'bin')), false, 'must not build');
}

for (const [template, shortName, kind] of [
    ['Cratis', 'cratis', 'web'],
    ['CratisAspire', 'cratis-aspire', 'aspire'],
]) {
    // Only the disposable copy loses post-actions; renderer inputs otherwise stay unchanged.
    const source = join(workspace, 'templates', template);
    cpSync(join(root, 'Templates', template), source, { recursive: true });
    const manifestFile = join(source, '.template.config/template.json');
    const manifest = JSON.parse(readFileSync(manifestFile, 'utf8'));
    manifest.postActions = [];
    writeFileSync(manifestFile, `${JSON.stringify(manifest, null, 4)}\n`);
    run('dotnet', ['new', 'install', source, ...hive]);
    for (const count of [1, 8, 9, 12]) {
        const name = Array.from({ length: count }, (_, index) => `S${index + 1}`).join('.');
        const application = join(workspace, `${template}-${count}`);
        run('dotnet', ['new', shortName, '--name', name, '--output', application,
            '--Framework', 'net10.0', '--no-update-check', ...hive]);
        verify(application, kind, name, count);
        if (cli) {
            const cliApplication = join(workspace, `${template}-${count}-cli`);
            run('cratis', ['new', shortName, '--template-path', source, '--language', 'csharp', '--framework', 'net10.0',
                '--name', name, '--output', cliApplication, '--allow-scripts', 'no']);
            verify(cliApplication, kind, name, count);
        }
    }
}
console.log('Verified both C# templates at 1, 8, 9 and 12 namespace segments without post-actions, restore or build');
