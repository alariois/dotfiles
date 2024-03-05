#/bin/sh

# TODO: automatically install necessary packages (cbor, mosquitto, etc)

SCRIPT_DIR="$(dirname $(realpath $0))"

create_link() {
    local file_path="$1"
    local file_name="$2"
    local target="$HOME/$file_name"

    if [ -e "$target" ]; then
        if [ -L "$target" ]; then
            echo "Target '$target' already exists as a link. Skipping."
            return
        else
            echo -n "Target '$target' exists and is not a link. Delete and create the link? (y/n) "
            read response < /dev/tty
            case $response in
                y|Y|yes|YES)
                    rm -rf "$target"
                    ;;
                *)
                    return
                    ;;
            esac
        fi
    fi

    echo "Creating a link from '$file_path' to '$target'"
    echo "  " ln -s "$file_path" "$target"
    ln -s "$file_path" "$target"
}
find "$SCRIPT_DIR" \
    -mindepth 1 \
    -maxdepth 1 \
    -not -name "*install.sh" \
    -not -name "*.gitignore" \
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
