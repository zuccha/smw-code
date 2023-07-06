#!/bin/bash

if [ "$1" = "" ]; then
    echo Missing script name
    echo Supported scripts: md2html
    exit 1
fi

if [ "$1" = "md2html" ]; then
    deno run --allow-read --allow-write .utils/md2html.ts "${@:2}"
    exit 0
fi

echo Unsupported script \"$1\"
echo Supported scripts: md2html
exit 1
