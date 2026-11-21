// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

// Checks a restored cratis-aspire solution's telemetry references and writes the runner
// that captures a Cratis span from it. Prints the application project on success.
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import process from 'node:process';

const [solution, runner, repo] = process.argv.slice(2);
if (!solution || !runner || !repo) {
    console.error('Usage: node prepare-runner.mjs <solution-directory> <runner-directory> <repository-root>');
    process.exit(1);
}

const errors = [];
const expect = (condition, message) => condition || errors.push(message);
const read = file => {
    expect(existsSync(file), `${file} must exist`);
    return existsSync(file) ? readFileSync(file, 'utf8') : '';
};
const assetsOf = project => JSON.parse(read(join(project, '..', 'obj', 'project.assets.json')) || '{"libraries":{},"project":{"frameworks":{}}}');
const versionsOf = (assets, id) => Object.keys(assets.libraries).filter(key => key.startsWith(`${id}/`)).map(key => key.split('/')[1]);

const solutionFiles = readdirSync(solution).filter(file => file.endsWith('.sln') || file.endsWith('.slnx'));
if (solutionFiles.length !== 1) {
    console.error(`Expected one solution file in ${solution}, found ${solutionFiles.length}`);
    process.exit(1);
}
const name = basename(solutionFiles[0]).replace(/\.slnx?$/, '');
const application = join(solution, name, `${name}.csproj`);
const infrastructure = join(solution, `${name}.Infrastructure`, `${name}.Infrastructure.csproj`);

// The Infrastructure project consumes the shared package instead of its own OpenTelemetry pipeline.
const infrastructureProject = read(infrastructure);
expect(/Include="Cratis\.OpenTelemetry"/.test(infrastructureProject), `${infrastructure} must reference Cratis.OpenTelemetry`);
expect(!/Include="OpenTelemetry[.\"]/.test(infrastructureProject), `${infrastructure} must not reference OpenTelemetry packages directly`);
const extensions = read(join(solution, `${name}.Infrastructure`, 'Extensions.cs'));
expect(extensions.includes('AddCratisOpenTelemetry('), 'Extensions.cs must use AddCratisOpenTelemetry');
for (const local of ['UseOtlpExporter(', 'Instrumentation(', 'AddOpenTelemetry(']) {
    expect(!extensions.includes(local), `Extensions.cs must not configure OpenTelemetry itself (${local})`);
}

// Restore resolved the shared package and one concrete version of each OpenTelemetry package.
const infrastructureAssets = assetsOf(infrastructure);
const direct = Object.values(infrastructureAssets.project.frameworks).flatMap(framework => Object.keys(framework.dependencies ?? {}));
expect(direct.includes('Cratis.OpenTelemetry'), 'Restore must list Cratis.OpenTelemetry as a direct dependency');
expect(!direct.some(id => id.startsWith('OpenTelemetry')), `Restore lists direct OpenTelemetry dependencies: ${direct.filter(id => id.startsWith('OpenTelemetry'))}`);
const telemetryPackages = [...new Set(Object.keys(infrastructureAssets.libraries).map(key => key.split('/')[0]).filter(id => id === 'Cratis.OpenTelemetry' || id.startsWith('OpenTelemetry')))];
for (const id of telemetryPackages) {
    const versions = versionsOf(infrastructureAssets, id);
    expect(versions.length === 1 && /^\d+\.\d+\.\d+/.test(versions[0]), `${id} must resolve to one concrete version, found ${versions}`);
}
const [openTelemetryVersion] = versionsOf(infrastructureAssets, 'OpenTelemetry');
expect(openTelemetryVersion, 'Restore must resolve the OpenTelemetry SDK through Cratis.OpenTelemetry');

const rootNamespace = /<RootNamespace>([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)<\/RootNamespace>/.exec(read(application))?.[1];
expect(rootNamespace, `${application} must declare an explicit C# RootNamespace`);
const cratisVersions = versionsOf(assetsOf(application), 'Cratis');
expect(cratisVersions.length === 1, `Could not determine ${name}'s resolved Cratis version`);

if (errors.length > 0) {
    errors.forEach(error => console.error(`::error::${error}`));
    process.exit(1);
}

mkdirSync(runner, { recursive: true });
// Insulate the runner from any ancestor build settings.
writeFileSync(join(runner, 'Directory.Build.props'), '<Project />\n');
// Lift the NU1605 downgrades: Cratis.Testing pins these at 10.0.x while Arc.Chronicle.Testing needs 11.0.0.
// Remove once Cratis.Testing is republished with matching versions (same list as verify-registration-identity.sh).
const lifted = ['System.Security.Cryptography.Pkcs', 'System.Security.Cryptography.Xml',
    'Microsoft.Extensions.Configuration.FileExtensions', 'Microsoft.Extensions.DependencyModel',
    'Microsoft.Extensions.Hosting', 'Microsoft.Extensions.Logging', 'Microsoft.Extensions.Logging.Debug'];
writeFileSync(join(runner, 'Telemetry.csproj'), `<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net11.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <ManagePackageVersionsCentrally>false</ManagePackageVersionsCentrally>
  </PropertyGroup>
  <ItemGroup>
    <ProjectReference Include="${application}" />
    <PackageReference Include="Cratis.Testing" Version="${cratisVersions[0]}" />
    <PackageReference Include="OpenTelemetry.Exporter.InMemory" Version="${openTelemetryVersion}" />
${lifted.map(id => `    <PackageReference Include="${id}" Version="11.0.0" />`).join('\n')}
  </ItemGroup>
</Project>
`);
const source = readFileSync(join(repo, 'Verification', 'Telemetry', 'Program.cs.txt'), 'utf8');
writeFileSync(join(runner, 'Program.cs'), source.replaceAll('TEMPLATE_NAMESPACE', rootNamespace));
console.error(`Checking ${rootNamespace} against Cratis ${cratisVersions[0]} and OpenTelemetry ${openTelemetryVersion}`);
console.log(application);
