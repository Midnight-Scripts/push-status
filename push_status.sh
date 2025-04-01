#!/usr/bin/env bash

# CONFIG
API_KEY="870bf5e863ed8ec795cd20396048e381"
ENDPOINT="https://midnight.voise.workers.dev/push"
CONTAINER_NAME="midnight"
PORT="9944"
USE_DOCKER=true

# FILE PATHS
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$HOME/midnight-node-docker/.env"
KEYS_FILE="$SCRIPT_DIR/partner-chains-public-keys.json"
RPC_URL="http://127.0.0.1:$PORT"

# Docker or host exec wrapper
exec_cmd() {
  [[ "$USE_DOCKER" == true ]] && docker exec "$CONTAINER_NAME" "$@" || eval "$@"
}

# Static info
NODE_KEY=$(grep -E '^NODE_KEY=' "$ENV_FILE" | cut -d= -f2 | tr -d '"')
NODE_VERSION=$(exec_cmd curl -s -X POST -d '{"jsonrpc":"2.0","id":1,"method":"system_version","params":[]}' \
  -H "Content-Type: application/json" "$RPC_URL" | jq -r '.result')

START_TIME=$(docker inspect -f '{{.State.StartedAt}}' "$CONTAINER_NAME" | cut -d'.' -f1)
UPTIME=$(uptime -p)

# Block info
LATEST_HEX=$(exec_cmd curl -s -X POST -d '{"jsonrpc":"2.0","id":1,"method":"chain_getHeader","params":[]}' \
  -H "Content-Type: application/json" "$RPC_URL" | jq -r '.result.number')
LATEST_BLOCK=$((LATEST_HEX))

FINALIZED_HASH=$(exec_cmd curl -s -X POST -d '{"jsonrpc":"2.0","id":1,"method":"chain_getFinalizedHead","params":[]}' \
  -H "Content-Type: application/json" "$RPC_URL" | jq -r '.result')
FINALIZED_HEX=$(exec_cmd curl -s -X POST -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"chain_getHeader\",\"params\":[\"$FINALIZED_HASH\"]}" \
  -H "Content-Type: application/json" "$RPC_URL" | jq -r '.result.number')
FINALIZED_BLOCK=$((FINALIZED_HEX))

# Sync info
SYNC_TARGET=$(exec_cmd curl -s -X POST -d '{"jsonrpc":"2.0","id":1,"method":"system_syncState","params":[]}' \
  -H "Content-Type: application/json" "$RPC_URL" | jq -r '.result.highestBlock')

if [[ $SYNC_TARGET -gt 0 ]]; then
  SYNC_PERCENT=$(awk "BEGIN{printf \"%.2f\",($LATEST_BLOCK/$SYNC_TARGET)*100}")
else
  SYNC_PERCENT="0.00"
fi

# Peers
PEERS=$(exec_cmd curl -s -X POST -d '{"jsonrpc":"2.0","id":1,"method":"system_peers","params":[]}' \
  -H "Content-Type: application/json" "$RPC_URL" | jq '.result | length')

# Blocks produced
BLOCKS_PRODUCED=$(curl -s http://127.0.0.1:9615/metrics | awk -F' ' '/substrate_tasks_ended_total{.*basic-authorship-proposer/ {print $2}')
[[ -z "$BLOCKS_PRODUCED" ]] && BLOCKS_PRODUCED=0

# Status
STATUS="idle"
[[ "$BLOCKS_PRODUCED" -gt 0 ]] && STATUS="minting"

# ─── KEY CHECKING (like live.sh) ─────────────────────
declare -A KEY_ITEMS=( ["grandpa_pub_key"]="gran" ["aura_pub_key"]="aura" ["sidechain_pub_key"]="crch" )
declare -A HAS_KEYS
declare -A PUBLIC_KEYS

# Load keys from JSON
for key in "${!KEY_ITEMS[@]}"; do
  PUBLIC_KEYS[$key]=$(jq -r ".${key}" "$KEYS_FILE")
done

# Run author_hasKey check
for key in "${!KEY_ITEMS[@]}"; do
  pub="${PUBLIC_KEYS[$key]}"
  result=$(exec_cmd curl -s -X POST -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"author_hasKey\",\"params\":[\"$pub\",\"${KEY_ITEMS[$key]}\"]}" \
    -H "Content-Type: application/json" "$RPC_URL" | jq -r '.result')
  HAS_KEYS[$key]=$result
done

# JSON payload
JSON=$(jq -n \
  --arg node_key "$NODE_KEY" \
  --arg version "$NODE_VERSION" \
  --arg started_at "$START_TIME" \
  --arg uptime "$UPTIME" \
  --argjson latest_block "$LATEST_BLOCK" \
  --argjson finalized_block "$FINALIZED_BLOCK" \
  --arg sync "$SYNC_PERCENT" \
  --argjson peers "$PEERS" \
  --argjson blocks "$BLOCKS_PRODUCED" \
  --arg status "$STATUS" \
  --argjson aura_found "${HAS_KEYS[aura_pub_key]}" \
  --argjson grandpa_found "${HAS_KEYS[grandpa_pub_key]}" \
  --argjson sidechain_found "${HAS_KEYS[sidechain_pub_key]}" \
  '{
    node_key: $node_key,
    midnight_version: $version,
    started_at: $started_at,
    uptime: $uptime,
    latest_block: $latest_block,
    finalized_block: $finalized_block,
    sync: $sync,
    peers: $peers,
    blocks_produced: $blocks,
    status: $status,
    keys: {
      aura: $aura_found,
      grandpa: $grandpa_found,
      sidechain: $sidechain_found
    }
  }')

# Send it
curl -s -X POST "$ENDPOINT" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON"
