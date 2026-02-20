#!/bin/bash
# pure-magic updater
# Usage: bash update.sh <target-directory>
# Or run from within the workspace: bash /path/to/pure-magic/update.sh

set -e

TARGET="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$TARGET/.claude/.pure-magic.json"

echo "pure-magic updater"
echo "Target: $TARGET"
echo ""

# Verify target exists
if [ ! -d "$TARGET" ]; then
  echo "Error: Target directory does not exist: $TARGET"
  exit 1
fi

# Verify manifest exists
if [ ! -f "$MANIFEST" ]; then
  echo "Error: No pure-magic installation found at $TARGET/.claude/.pure-magic.json"
  echo "Run install.sh first."
  exit 1
fi

# Read installed version from manifest
INSTALLED_VERSION=$(grep '"version"' "$MANIFEST" | sed 's/.*"version": *"\([^"]*\)".*/\1/')

# Read available version from source
AVAILABLE_VERSION=$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null | tr -d '[:space:]')

echo "Installed version : $INSTALLED_VERSION"
echo "Available version : $AVAILABLE_VERSION"
echo "Source            : $SCRIPT_DIR"
echo ""

# Diff each managed directory and collect changed files
CHANGED=()
NEW=()
REMOVED=()

check_dir() {
  local src="$1"
  local dest="$2"
  local label="$3"

  for src_file in "$src/"*.md; do
    [ -f "$src_file" ] || continue
    filename=$(basename "$src_file")
    dest_file="$dest/$filename"

    if [ ! -f "$dest_file" ]; then
      NEW+=("$label/$filename")
    elif ! diff -q "$src_file" "$dest_file" > /dev/null 2>&1; then
      CHANGED+=("$label/$filename")
    fi
  done

  for dest_file in "$dest/"*.md; do
    [ -f "$dest_file" ] || continue
    filename=$(basename "$dest_file")
    src_file="$src/$filename"
    if [ ! -f "$src_file" ]; then
      REMOVED+=("$label/$filename")
    fi
  done
}

check_dir "$SCRIPT_DIR/commands/pm" "$TARGET/.claude/commands/pm" "commands/pm"
check_dir "$SCRIPT_DIR/.claude/rules" "$TARGET/.claude/rules" "rules"
check_dir "$SCRIPT_DIR/templates" "$TARGET/.claude/templates" "templates"

TOTAL=$(( ${#CHANGED[@]} + ${#NEW[@]} + ${#REMOVED[@]} ))

if [ "$TOTAL" -eq 0 ]; then
  echo "Everything is up to date. No changes to apply."
  exit 0
fi

echo "Changes available:"

if [ ${#NEW[@]} -gt 0 ]; then
  echo ""
  echo "  New files:"
  for f in "${NEW[@]}"; do echo "    + $f"; done
fi

if [ ${#CHANGED[@]} -gt 0 ]; then
  echo ""
  echo "  Modified files:"
  for f in "${CHANGED[@]}"; do echo "    ~ $f"; done
fi

if [ ${#REMOVED[@]} -gt 0 ]; then
  echo ""
  echo "  Removed from source (not auto-deleted, remove manually if no longer needed):"
  for f in "${REMOVED[@]}"; do echo "    - $f"; done
fi

echo ""
read -p "Apply these changes? [y/N] " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
  echo "Cancelled. No changes applied."
  exit 0
fi

echo ""
echo "Applying update..."

copy_dir() {
  local src="$1"
  local dest="$2"
  local label="$3"

  mkdir -p "$dest"
  cp "$src/"*.md "$dest/" 2>/dev/null || true
  echo "  updated: $label"
}

copy_dir "$SCRIPT_DIR/commands/pm" "$TARGET/.claude/commands/pm" "commands/pm"
copy_dir "$SCRIPT_DIR/.claude/rules" "$TARGET/.claude/rules" "rules"
copy_dir "$SCRIPT_DIR/templates" "$TARGET/.claude/templates" "templates"

# Update manifest
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > "$MANIFEST" << EOF
{
  "version": "$AVAILABLE_VERSION",
  "source": "$SCRIPT_DIR",
  "installed": "$TIMESTAMP"
}
EOF

echo ""
echo "Done. Updated to pure-magic $AVAILABLE_VERSION"
echo ""
echo "Note: .claude/overrides/ and .claude/settings.local.json were not touched."
