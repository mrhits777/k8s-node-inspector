#!/bin/bash

# k8s-node-inspector.sh
# Author: Jeremy Martinez
# Purpose: Audit Kubernetes worker nodes for health, imbalance, resource pressure,
#          pod states, taints, and other SRE-relevant data.

set -euo pipefail
IFS=$'\n\t'

### CONFIGURATION
KUBECTL_BIN="kubectl"
OUTPUT_FILE="k8s_node_audit_$(date +%F_%H%M).log"

### DEPENDENCY CHECK
for cmd in $KUBECTL_BIN jq; do
  if ! command -v $cmd &>/dev/null; then
    echo "ERROR: $cmd is not installed or not in PATH." >&2
    exit 1
  fi
done

### HEADER
echo "🔍 Kubernetes Node Audit Report - $(date)" | tee "$OUTPUT_FILE"
echo "Cluster Context: $($KUBECTL_BIN config current-context)" | tee -a "$OUTPUT_FILE"
echo "Namespace: default" | tee -a "$OUTPUT_FILE"
echo "-------------------------------------------------------------" | tee -a "$OUTPUT_FILE"

### NODE LOOP
NODES=$($KUBECTL_BIN get nodes -o json | jq -r '.items[].metadata.name')

for NODE in $NODES; do
  echo "\nNode: $NODE" | tee -a "$OUTPUT_FILE"
  echo "-------------------------" | tee -a "$OUTPUT_FILE"

  # General status
  $KUBECTL_BIN describe node "$NODE" | grep -E "Roles|OS-Image|Kernel|Container Runtime" | tee -a "$OUTPUT_FILE"

  # Taints
  TAINTS=$($KUBECTL_BIN get node "$NODE" -o json | jq -r '.spec.taints // [] | .[] | "- " + (.key + ":" + .value + " (" + .effect + ")")')
  echo "Taints:" | tee -a "$OUTPUT_FILE"
  [[ -z "$TAINTS" ]] && echo "- None" | tee -a "$OUTPUT_FILE" || echo "$TAINTS" | tee -a "$OUTPUT_FILE"

  # Conditions
  echo "Conditions:" | tee -a "$OUTPUT_FILE"
  $KUBECTL_BIN get node "$NODE" -o json | jq -r '.status.conditions[] | "- " + .type + ": " + .status + " (last updated: " + .lastTransitionTime + ")"' | tee -a "$OUTPUT_FILE"

  # Resource pressure
  echo "Resource Pressure:" | tee -a "$OUTPUT_FILE"
  $KUBECTL_BIN describe node "$NODE" | grep -A6 "Non-terminated Pods" | tee -a "$OUTPUT_FILE"

  # Allocatable vs capacity
  echo "Allocatable vs Capacity:" | tee -a "$OUTPUT_FILE"
  $KUBECTL_BIN get node "$NODE" -o json | jq -r '.status | "CPU: " + .capacity.cpu + "/" + .allocatable.cpu, "Memory: " + .capacity.memory + "/" + .allocatable.memory, "Pods: " + .capacity.pods + "/" + .allocatable.pods' | tee -a "$OUTPUT_FILE"

  # Pod count & distribution
  echo "Pods Running on Node:" | tee -a "$OUTPUT_FILE"
  $KUBECTL_BIN get pods --all-namespaces -o wide --field-selector spec.nodeName="$NODE" | tee -a "$OUTPUT_FILE"

done

### SUMMARY
echo "\n✅ Audit Complete. Output written to $OUTPUT_FILE"

exit 0
