#/bin/sh

SCRIPT_DIR="$(dirname $(realpath $0))"

create_link() {
    local file_path="$1"
    local file_name=$(basename "${file_path}")

    ln -s "$file_path" "$HOME/$file_name"
}

find "$SCRIPT_DIR" \
    -mindepth 1 \
    -maxdepth 1 \
    -not -name "*install.sh" \
    -not -path "*/.git*" \
    -print0 \
  | while IFS= read -r -d '' file; do
        create_link "$file"
    done

