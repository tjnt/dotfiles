#!/bin/sh

cd $(dirname $0)

for f in `find . -type d -name '.git' -prune -o -type f -print | \
    sed -e 's/^\.\///g'`
do
    if [ "`basename $0`" = "$f" -o "mklink.bat" = $f ]; then
        continue
    fi
    mkdir -p `dirname "$HOME/$f"`
    ln -sfv "$PWD/$f" "$HOME/$f"
done

