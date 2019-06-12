#!/usr/bin/env bash
set -e

if [[ $OSTYPE == "darwin"* ]]; then
    libtoolbin=$(command -v otool)
    libtoolopts='-L'
else
    libtoolbin=$(command -v -- scanelf readelf greadelf | head -n1)
    libtoolopts='-n'
fi

declare -r libtool="${libtoolbin}"
declare -r sed=$(command -v -- gsed sed | head -n1)
declare -r sedopts='-Ene'
declare -r profanity="$(command -v profanity)"

test -x "${libtoolbin}" || echo -n 'Couldnt find suitable binary, please be sure you have otool/readelf installed and accessible from current $PATH.'
test -x "${sed}" || echo -n 'You should have sed/gsed installed and accessible from current $PATH.'
test -x "${profanity}"

command -v tail > /dev/null
command -v cut > /dev/null
command -v tr > /dev/null
command -v sed > /dev/null

python_version="$("${libtool}" "${libtoolopts}" "${profanity}" | tail -n+2 | cut -d' ' -f2 | tr , '\n' | ${sed} ${sedopts} 's/^libpython([0-9]+\.[0-9]+).*$/\1/p')"

python"${python_version}" setup.py install --force --user --prefix=
mkdir -p ~/.local/share/profanity/plugins
cp deploy/prof_omemo_plugin.py ~/.local/share/profanity/plugins/
