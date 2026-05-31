#!/usr/bin/env bash
set -e

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copy_commands() {
    local src="$1" dest="$2"
    local new=0 updated=0

    [ -d "$src" ] || {
        echo "  (none)"
        return
    }
    mkdir -p "$dest"

    for file in "$src"/*.md; do
        [ -f "$file" ] || continue
        name="$(basename "$file")"
        dest_file="$dest/$name"
        if [ ! -f "$dest_file" ]; then
            cp "$file" "$dest_file"
            echo "  + $name"
            ((new++))
        elif ! cmp -s "$file" "$dest_file"; then
            cp "$file" "$dest_file"
            echo "  ↑ $name (updated)"
            ((updated++))
        fi
    done
    echo "  → $new new, $updated updated"
}

copy_skills() {
    local src="$1" dest="$2"
    local new=0 updated=0

    [ -d "$src" ] || {
        echo "  (none)"
        return
    }
    mkdir -p "$dest"

    for skill_dir in "$src"/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name="$(basename "$skill_dir")"
        dest_skill="$dest/$skill_name"
        mkdir -p "$dest_skill"

        for file in "$skill_dir"*; do
            [ -f "$file" ] || continue
            name="$(basename "$file")"
            dest_file="$dest_skill/$name"
            if [ ! -f "$dest_file" ]; then
                cp "$file" "$dest_file"
                echo "  + $skill_name/$name"
                ((new++))
            elif ! cmp -s "$file" "$dest_file"; then
                cp "$file" "$dest_file"
                echo "  ↑ $skill_name/$name (updated)"
                ((updated++))
            fi
        done
    done
    echo "  → $new new, $updated updated"
}

echo "Commands:"
copy_commands "$REPO/commands" "$HOME/.claude/commands"

echo "Skills:"
copy_skills "$REPO/skills" "$HOME/.claude/skills"

echo "Done."
