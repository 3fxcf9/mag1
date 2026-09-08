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

optimize-figure file:
	#!/usr/bin/env bash

	echo "Processing {{file}}"

	inkscape \
	  --export-plain-svg \
	  --export-area-drawing \
	  {{file}} -o {{file}}

	tmp=$(mktemp)

	if scour --quiet \
		--strip-xml-prolog \
		--enable-id-stripping \
		--enable-comment-stripping \
		--shorten-ids-prefix=PREFIX \
		--remove-metadata \
		-i {{file}} -o "$tmp"; then
		mv "$tmp" {{file}}
	else
		rm -f "$tmp"
		exit 1
	fi


optimize-figures dir=".":
	#!/usr/bin/env bash

	echo "Optimizing svg figures..."

	set -e

	find {{dir}} -type f -path '*/figures/*.svg' -print0 |
	while IFS= read -r -d '' file; do
		just optimize-figure "$file"
	done

optimize-figures-staged:
	#!/usr/bin/env bash
	git diff --cached --name-only --diff-filter=ACMR -- '*.svg' |
	while IFS= read -r file; do
		just optimize-figure "$file"
	done

optimize-figures-modified:
	#!/bin/sh
	{ \
		git diff --name-only --diff-filter=ACMR -- '*.svg'; \
		git ls-files --others --exclude-standard -- '*.svg'; \
	} | sort -u | while IFS= read -r file; do \
		just optimize-figure "$file"; \
	done


# Setup git commit hooks
hook:
	cp ./_git_hooks/* .git/hooks
