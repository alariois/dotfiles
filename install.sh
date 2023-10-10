#/bin/sh

SCRIPT_DIR="$(dirname $(realpath $0))"

create_link() {
    local file_path="$1"
    local file_name="$2"

    echo ln -s "$file_path" "$HOME/$file_name"
    ln -s "$file_path" "$HOME/$file_name"
}

find "$SCRIPT_DIR" \
    -mindepth 1 \
    -maxdepth 1 \
    -not -name "*install.sh" \
    -not -path "*/.git" \
    -not -path "*/.config" \
    -print0 \
  | while IFS= read -r -d '' file; do
	create_link "$file" "$(basename "${file}")"
    done

find "$SCRIPT_DIR/.config" \
    -mindepth 1 \
    -maxdepth 1 \
    -print0 \
  | while IFS= read -r -d '' file; do
	create_link "$file" ".config/$(basename "${file}")"
    done
