default: serve

build out:
    #!/usr/bin/env bash
    set -e
    cd ~/DEV/git/markup
    dune exec ./main/main.exe -- --debug ~/School/Mag1 {{out}}
    python3 -m http.server 8080 -d {{out}}

serve:
    #!/usr/bin/env bash
    set -e
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT

    just build "$tmp"


optimize-figures:
    #!/usr/bin/env bash

    echo "Optimizing svg figures..."

    set -e

    find . -type f -path '*/figures/*.svg' -print0 |
    while IFS= read -r -d '' file; do
        echo "Processing $file"

        inkscape \
          --export-plain-svg \
          --export-area-drawing \
          "$file" -o "$file"

        tmp=$(mktemp)

        if scour --quiet \
          --strip-xml-prolog \
          --enable-id-stripping \
          --enable-comment-stripping \
          --shorten-ids-prefix=PREFIX \
          --remove-metadata \
          -i "$file" -o "$tmp"; then
            mv "$tmp" "$file"
        else
            rm -f "$tmp"
            exit 1
        fi
    done


# Setup git commit hooks
hook:
  cp ./git_hooks/* .git/hooks
