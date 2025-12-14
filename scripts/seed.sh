#!/usr/bin/env bash
set -euo pipefail


echo "Seeding Kafka topics..."
# Use Redpanda's rpk inside the container
TOPICS=(telemetry.raw orders.raw incidents.events)
for t in "${TOPICS[@]}"; do
docker exec -i deploy-redpanda-1 rpk topic create "$t" -p 3 || true
# If your compose container name differs, run: docker ps | grep redpanda
done


echo "Enabling Timescale extension..."
docker exec -i deploy-postgres-1 psql -U ops -d opsdb -c "CREATE EXTENSION IF NOT EXISTS timescaledb;" || true


echo "✅ Seed complete."