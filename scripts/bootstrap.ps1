$ErrorActionPreference = "Stop"


if (-not (Test-Path RestaurantOperationsPlatform.sln)) {
dotnet new sln -n RestaurantOperationsPlatform
}


$projects = @("Common","IngestionGateway","AnalyticsWorker","IncidentEngine","InsightApi","DeviceSimulator")


if (-not (Test-Path src/Common/Common.csproj)) { dotnet new classlib -n Common -o src/Common }
if (-not (Test-Path src/IngestionGateway/IngestionGateway.csproj)) { dotnet new web -n IngestionGateway -o src/IngestionGateway }
if (-not (Test-Path src/AnalyticsWorker/AnalyticsWorker.csproj)) { dotnet new worker -n AnalyticsWorker -o src/AnalyticsWorker }
if (-not (Test-Path src/IncidentEngine/IncidentEngine.csproj)) { dotnet new worker -n IncidentEngine -o src/IncidentEngine }
if (-not (Test-Path src/InsightApi/InsightApi.csproj)) { dotnet new webapi -n InsightApi -o src/InsightApi }
if (-not (Test-Path src/DeviceSimulator/DeviceSimulator.csproj)) { dotnet new worker -n DeviceSimulator -o src/DeviceSimulator }


foreach ($p in $projects) {
dotnet sln RestaurantOperationsPlatform.sln add src/$p/$p.csproj | Out-Null
}


foreach ($p in $projects) {
if ($p -ne "Common") { dotnet add src/$p/$p.csproj reference src/Common/Common.csproj | Out-Null }
}


$commonPkgs = @("Confluent.Kafka","OpenTelemetry.Exporter.Otlp","OpenTelemetry.Extensions.Hosting","Serilog.AspNetCore","StackExchange.Redis","Polly")
foreach ($p in $projects) {
if ($p -ne "Common") {
foreach ($pkg in $commonPkgs) { dotnet add src/$p/$p.csproj package $pkg | Out-Null }
}
}


dotnet add src/IngestionGateway/IngestionGateway.csproj package Grpc.AspNetCore | Out-Null


dotnet add src/DeviceSimulator/DeviceSimulator.csproj package Grpc.Net.Client | Out-Null


dotnet restore
Write-Host "✅ Bootstrap complete."