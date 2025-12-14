#!/usr/bin/env bash
set -euo pipefail


# Solution
if [ ! -f RestaurantOperationsPlatform.sln ]; then
dotnet new sln -n RestaurantOperationsPlatform
fi


# Projects (created only if missing)
mkdir -p src/Common src/IngestionGateway src/AnalyticsWorker src/IncidentEngine src/InsightApi src/DeviceSimulator contracts deploy scripts


[ -f src/Common/Common.csproj ] || dotnet new classlib -n Common -o src/Common
[ -f src/IngestionGateway/IngestionGateway.csproj ] || dotnet new web -n IngestionGateway -o src/IngestionGateway
[ -f src/AnalyticsWorker/AnalyticsWorker.csproj ] || dotnet new worker -n AnalyticsWorker -o src/AnalyticsWorker
[ -f src/IncidentEngine/IncidentEngine.csproj ] || dotnet new worker -n IncidentEngine -o src/IncidentEngine
[ -f src/InsightApi/InsightApi.csproj ] || dotnet new webapi -n InsightApi -o src/InsightApi
[ -f src/DeviceSimulator/DeviceSimulator.csproj ] || dotnet new worker -n DeviceSimulator -o src/DeviceSimulator


# Add to solution
for p in Common IngestionGateway AnalyticsWorker IncidentEngine InsightApi DeviceSimulator; do
dotnet sln RestaurantOperationsPlatform.sln add src/$p/$p.csproj 2>/dev/null || true
done


# Project references
for p in IngestionGateway AnalyticsWorker IncidentEngine InsightApi DeviceSimulator; do
dotnet add src/$p/$p.csproj reference src/Common/Common.csproj 2>/dev/null || true
done


# Packages
COMMON_PKGS=(Confluent.Kafka OpenTelemetry.Exporter.Otlp OpenTelemetry.Extensions.Hosting Serilog.AspNetCore StackExchange.Redis Polly)
for p in IngestionGateway AnalyticsWorker IncidentEngine InsightApi DeviceSimulator; do
for pkg in "${COMMON_PKGS[@]}"; do
dotnet add src/$p/$p.csproj package $pkg 2>/dev/null || true
done
done


# gRPC server for gateway, gRPC client for simulator
(dotnet list src/IngestionGateway/IngestionGateway.csproj package | grep -q Grpc.AspNetCore) || dotnet add src/IngestionGateway/IngestionGateway.csproj package Grpc.AspNetCore
(dotnet list src/DeviceSimulator/DeviceSimulator.csproj package | grep -q Grpc.Net.Client) || dotnet add src/DeviceSimulator/DeviceSimulator.csproj package Grpc.Net.Client


# Ensure contracts folder exists
mkdir -p contracts


dotnet restore


echo "✅ Bootstrap complete: RestaurantOperationsPlatform.sln ready."