#!/bin/sh
set -eu

# Keep user-supplied tables and symlinks in a mounted working directory.
for file in /opt/gsm/data/*; do
    name=${file##*/}
    if [ ! -e "$name" ] && [ ! -L "$name" ]; then
        cp "$file" "$name"
    fi
done
exec "$@"
