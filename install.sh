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

# Create .claude directories
mkdir -p "$TARGET/.claude/commands/pm"
mkdir -p "$TARGET/.claude/rules"

# Copy commands
echo "Installing commands..."
for file in "$SCRIPT_DIR/commands/pm/"*.md; do
  filename=$(basename "$file")
  dest="$TARGET/.claude/commands/pm/$filename"
  if [ -f "$dest" ]; then
    read -p "  $filename already exists. Overwrite? [y/N] " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      echo "  Skipped $filename"
      continue
    fi
  fi
  cp "$file" "$dest"
  echo "  + commands/pm/$filename"
done

# Copy rules
echo "Installing rules..."
for file in "$SCRIPT_DIR/.claude/rules/"*.md; do
  filename=$(basename "$file")
  dest="$TARGET/.claude/rules/$filename"
  if [ -f "$dest" ]; then
    read -p "  $filename already exists. Overwrite? [y/N] " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      echo "  Skipped $filename"
      continue
    fi
  fi
  cp "$file" "$dest"
  echo "  + rules/$filename"
done

# Copy templates
echo "Installing templates..."
mkdir -p "$TARGET/.claude/templates"
for file in "$SCRIPT_DIR/templates/"*.md; do
  filename=$(basename "$file")
  dest="$TARGET/.claude/templates/$filename"
  if [ -f "$dest" ]; then
    read -p "  $filename already exists. Overwrite? [y/N] " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
      echo "  Skipped $filename"
      continue
    fi
  fi
  cp "$file" "$dest"
  echo "  + templates/$filename"
done

# Update settings.local.json with gh permissions
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
  echo "Created .claude/settings.local.json with gh permissions"
else
  echo ""
  echo "Note: .claude/settings.local.json already exists."
  echo "Make sure it allows: Bash(gh:*)"
  echo "This is required for /pm:sync and /pm:status to work."
fi

echo ""
echo "Done. pure-magic is installed at $TARGET/.claude/"
echo ""
echo "Next steps:"
echo "  1. For each project, create a pm-config.md in its folder:"
echo "     Copy from .claude/templates/pm-config.md and fill in your GitHub repo."
echo ""
echo "  2. Make sure GitHub CLI is authenticated:"
echo "     gh auth status"
echo ""
echo "  3. Start with your first spec:"
echo "     /pm:spec <project> <feature-name>"
