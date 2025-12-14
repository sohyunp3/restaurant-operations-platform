SHELL := /bin/bash


.PHONY: up down logs seed bootstrap restore build test run-gateway run-sim


up:
cd deploy && docker compose up -d


down:
cd deploy && docker compose down -v


logs:
cd deploy && docker compose logs -f


seed:
bash scripts/seed.sh


bootstrap:
bash scripts/bootstrap.sh


restore:
dotnet restore


build:
dotnet build -c Release


test:
dotnet test -c Release


run-gateway:
KAFKA_BOOTSTRAP=localhost:9092 dotnet run --project src/IngestionGateway/IngestionGateway.csproj --urls http://0.0.0.0:5011


run-sim:
dotnet run --project src/DeviceSimulator/DeviceSimulator.csproj