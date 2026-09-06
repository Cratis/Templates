#!/usr/bin/env bash
# Copyright (c) Cratis. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
set -euo pipefail

# Run the actual scaffolded Register command through Arc's command pipeline,
# project its appended event, and load that state from a follow-up command.
# Test-only dependencies live in a separate runner, never in a shipped template.
# Usage: ./verify-registration-identity.sh <scaffolded-app-directory>...
# Each app directory must contain its .csproj (not the Aspire AppHost).

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <scaffolded-app-directory>..." >&2
    exit 1
fi

mkdir -p "$repo_root/.ai-work"
work_dir="$(mktemp -d "$repo_root/.ai-work/registration-identity.XXXXXX")"
echo "Registration identity verification artifacts: $work_dir"

index=0
for app in "$@"; do
    app="$(cd "$app" && pwd)"
    project="$(python3 - "$app" <<'PY'
import pathlib, sys
projects = list(pathlib.Path(sys.argv[1]).glob('*.csproj'))
if len(projects) != 1:
    raise SystemExit(f'Expected one application project in {sys.argv[1]}, found {len(projects)}')
print(projects[0])
PY
)"
    # Regenerate rather than checking the template's old placeholder proxies.
    dotnet build "$project" --configuration Debug
    runner="$work_dir/$index"
    python3 - "$project" "$runner" "$repo_root" <<'PY'
import json, pathlib, re, sys, xml.etree.ElementTree as ET
project, runner, repo = map(pathlib.Path, sys.argv[1:])
root_namespace = ET.parse(project).getroot().findtext('.//RootNamespace')
if not root_namespace or not re.fullmatch(r'[A-Za-z_][\w]*(\.[A-Za-z_][\w]*)*', root_namespace):
    raise SystemExit('Expected an explicit C# RootNamespace in the scaffolded project')
assets = json.loads((project.parent / 'obj/project.assets.json').read_text())
versions = [key.split('/', 1)[1] for key in assets['libraries'] if key.startswith('Cratis/')]
if len(versions) != 1:
    raise SystemExit('Could not determine the scaffolded app\'s resolved Cratis version')
proxy = project.parent / 'SomeModule/SomeFeature/Registration/Registration.ts'
text = proxy.read_text()
if not re.search(r'class\s+Register\s+extends\s+Command<IRegister,\s*Guid>', text):
    raise SystemExit('Register proxy no longer exposes a Guid command response')
if not re.search(r'super\(Guid,\s*false\)', text):
    raise SystemExit('Register proxy no longer deserializes its response as Guid')
runner.mkdir(parents=True)
# Insulate the runner from any ancestor build settings. Cratis.Testing supports
# net10; it can reference a scaffold targeting an earlier supported framework.
(runner / 'Directory.Build.props').write_text('<Project />\n')
csproj = ET.Element('Project', Sdk='Microsoft.NET.Sdk')
props = ET.SubElement(csproj, 'PropertyGroup')
for name, value in {'OutputType': 'Exe', 'TargetFramework': 'net10.0',
                    'ImplicitUsings': 'enable', 'Nullable': 'enable',
                    'TreatWarningsAsErrors': 'true',
                    'ManagePackageVersionsCentrally': 'false'}.items():
    ET.SubElement(props, name).text = value
items = ET.SubElement(csproj, 'ItemGroup')
ET.SubElement(items, 'ProjectReference', Include=str(project))
ET.SubElement(items, 'PackageReference', Include='Cratis.Testing', Version=versions[0])
ET.indent(csproj)
ET.ElementTree(csproj).write(runner / 'RegistrationIdentity.csproj', encoding='unicode')
source = (repo / 'Verification/RegistrationIdentity/Program.cs.txt').read_text()
(runner / 'Program.cs').write_text(source.replace('TEMPLATE_NAMESPACE', root_namespace))
print(f'Checking {root_namespace} against its resolved Cratis {versions[0]}')
PY
    dotnet run --project "$runner/RegistrationIdentity.csproj" --configuration Debug -p:CratisProxiesOutputPath=
    index=$((index + 1))
done
