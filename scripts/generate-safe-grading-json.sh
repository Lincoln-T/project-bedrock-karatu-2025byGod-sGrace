#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"
OUTPUT_FILE="$PROJECT_ROOT/grading.json"
TEMP_FILE="$(mktemp)"

cleanup() {
  rm -f "$TEMP_FILE"
}
trap cleanup EXIT

cd "$TERRAFORM_DIR"

terraform output -json | python3 -c '
import json
import sys

outputs = json.load(sys.stdin)

for name, output in outputs.items():
    if output.get("sensitive") is True:
        output["value"] = "REDACTED - provided privately to the instructor"
        output["security_note"] = (
            "This Terraform output is sensitive and is intentionally excluded "
            "from the public repository."
        )

json.dump(outputs, sys.stdout, indent=2)
print()
' > "$TEMP_FILE"

mv "$TEMP_FILE" "$OUTPUT_FILE"
chmod 644 "$OUTPUT_FILE"

echo "Generated sanitized grading.json at:"
echo "$OUTPUT_FILE"
echo "All Terraform outputs marked sensitive were automatically redacted."
