#!/usr/bin/env bash
# Copies rules and templates from the plugin into the workspace .claude/ directory.
# Skips files that already exist (preserves overrides).
# Runs on SessionStart.

set -euo pipefail
shopt -s nullglob

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
WORKSPACE_ROOT="${CLAUDE_PROJECT_ROOT:-$(pwd)}"

RULES_SRC="$PLUGIN_ROOT/rules"
TEMPLATES_SRC="$PLUGIN_ROOT/templates"

RULES_DEST="$WORKSPACE_ROOT/.claude/rules"
TEMPLATES_DEST="$WORKSPACE_ROOT/.claude/templates"
OVERRIDES_RULES="$WORKSPACE_ROOT/.claude/overrides/rules"
OVERRIDES_TEMPLATES="$WORKSPACE_ROOT/.claude/overrides/templates"

mkdir -p "$RULES_DEST" "$TEMPLATES_DEST" "$OVERRIDES_RULES" "$OVERRIDES_TEMPLATES"

# Copy rules, skipping files that already exist
for src_file in "$RULES_SRC"/*.md; do
  filename="$(basename "$src_file")"
  dest_file="$RULES_DEST/$filename"
  if [ ! -f "$dest_file" ]; then
    cp "$src_file" "$dest_file"
  fi
done

# Copy templates, skipping files that already exist
for src_file in "$TEMPLATES_SRC"/*.md; do
  filename="$(basename "$src_file")"
  dest_file="$TEMPLATES_DEST/$filename"
  if [ ! -f "$dest_file" ]; then
    cp "$src_file" "$dest_file"
  fi
done
