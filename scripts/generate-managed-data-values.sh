#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
OUTPUT="terraform/managed-data-values.yaml"

CATALOG_HOST=$(aws rds describe-db-instances \
  --db-instance-identifier project-bedrock-catalog-mysql \
  --region "$REGION" \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)

ORDERS_HOST=$(aws rds describe-db-instances \
  --db-instance-identifier project-bedrock-orders-postgres \
  --region "$REGION" \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)

CATALOG_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id project-bedrock/catalog-db \
  --region "$REGION" \
  --query SecretString \
  --output text)

ORDERS_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id project-bedrock/orders-db \
  --region "$REGION" \
  --query SecretString \
  --output text)

export CATALOG_HOST ORDERS_HOST CATALOG_SECRET ORDERS_SECRET OUTPUT

python3 <<'PY'
import json
import os
from pathlib import Path

catalog = json.loads(os.environ["CATALOG_SECRET"])
orders = json.loads(os.environ["ORDERS_SECRET"])

content = f"""cart:
  app:
    persistence:
      provider: dynamodb
      dynamodb:
        tableName: Items
        createTable: false
  dynamodb:
    create: false

catalog:
  app:
    persistence:
      provider: mysql
      endpoint: {os.environ["CATALOG_HOST"]}:3306
      database: catalog
      secret:
        create: true
        name: catalog-db
        username: {catalog["username"]}
        password: {json.dumps(catalog["password"])}

orders:
  app:
    persistence:
      provider: postgres
      endpoint: {os.environ["ORDERS_HOST"]}:5432
      database: orders
      secret:
        create: true
        name: orders-db
        username: {orders["username"]}
        password: {json.dumps(orders["password"])}
"""

path = Path(os.environ["OUTPUT"])
path.write_text(content)
path.chmod(0o600)

print(f"Generated private Helm values at {path}")
print("This file is ignored by Git.")
PY

unset CATALOG_SECRET ORDERS_SECRET
