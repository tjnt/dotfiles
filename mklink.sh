#!/bin/sh

cd $(dirname $0)

for f in `find . -type d -name '.git' -prune -o -type f -print | \
    sed -e 's/^\.\///g'`
do
    if [ "`basename $0`" = "$f" ]; then
        continue
    fi
    ln -snfv "$PWD/$f" "$HOME/$f"
done

