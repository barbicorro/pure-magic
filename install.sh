#!/bin/bash
# pure-magic installer
# Usage: bash install.sh <target-directory>
# Example: bash install.sh /Users/you/Documents/Notes/my-workspace

set -e

TARGET="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "pure-magic installer"
echo "Target: $TARGET"
echo ""

# Verify target exists
if [ ! -d "$TARGET" ]; then
  echo "Error: Target directory does not exist: $TARGET"
  exit 1
fi

# Copy a directory, removing symlinks first if migrating from old install
copy_dir() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [ -L "$dest" ]; then
    rm "$dest"
    echo "  removed old symlink: $label"
  fi

  mkdir -p "$dest"
  cp "$src/"*.md "$dest/" 2>/dev/null || true
  echo "  copied: $label"
}

# Copy all managed directories
echo "Installing files..."
for skill_src in "$SCRIPT_DIR/.claude/skills"/pm-*/; do
  skill_name=$(basename "$skill_src")
  skill_dest="$TARGET/.claude/skills/$skill_name"
  mkdir -p "$skill_dest"
  cp "$skill_src/SKILL.md" "$skill_dest/SKILL.md"
  echo "  copied: skills/$skill_name"
done
copy_dir "$SCRIPT_DIR/.claude/rules" "$TARGET/.claude/rules" "rules"
copy_dir "$SCRIPT_DIR/templates" "$TARGET/.claude/templates" "templates"

# Create override directories
echo ""
echo "Creating override directories..."
mkdir -p "$TARGET/.claude/overrides/rules"
mkdir -p "$TARGET/.claude/overrides/templates"
echo "  .claude/overrides/rules/     (place custom rules here)"
echo "  .claude/overrides/templates/ (place custom templates here)"

# Create settings.local.json with gh permissions
SETTINGS="$TARGET/.claude/settings.local.json"
if [ ! -f "$SETTINGS" ]; then
  cat > "$SETTINGS" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(gh:*)"
    ]
  }
}
EOF
  echo ""
  echo "Created .claude/settings.local.json with gh permissions"
else
  echo ""
  echo "Note: .claude/settings.local.json already exists."
  echo "Make sure it allows: Bash(gh:*)"
  echo "This is required for /pm-sync and /pm-status to work."
fi

# Write manifest
VERSION=$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null | tr -d '[:space:]')
INSTALLED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
MANIFEST="$TARGET/.claude/.pure-magic.json"

cat > "$MANIFEST" << EOF
{
  "version": "$VERSION",
  "source": "$SCRIPT_DIR",
  "installed": "$INSTALLED"
}
EOF
echo ""
echo "Wrote manifest: .claude/.pure-magic.json (version $VERSION)"

echo ""
echo "Done. pure-magic $VERSION is installed at $TARGET/.claude/"
echo ""
echo "To update pure-magic in this workspace later:"
echo "  bash \"$SCRIPT_DIR/update.sh\" \"$TARGET\""
echo ""
echo "To customize rules or templates for this project only:"
echo "  Copy a file into the overrides directory and edit it there."
echo "  Skills use the override when present, the default otherwise."
echo ""
echo "  .claude/overrides/rules/<name>.md     overrides .claude/rules/<name>.md"
echo "  .claude/overrides/templates/<name>.md overrides .claude/templates/<name>.md"
echo ""
echo "Next steps:"
echo "  1. For each project, create a pm-config.md in its folder:"
echo "     Copy from .claude/templates/pm-config.md and fill in your GitHub repo."
echo ""
echo "  2. Make sure GitHub CLI is authenticated:"
echo "     gh auth status"
echo ""
echo "  3. Start with your first spec:"
echo "     /pm-spec <project> <feature-name>"
