#!/bin/sh
dotnet new uninstall Cratis.Templates
dotnet pack Cratis.Templates.csproj -c Release -o ./nupkgs
cd ./nupkgs
dotnet new install Cratis.Templates.1.0.0.nupkg