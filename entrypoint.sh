#!/bin/bash
set -e
ls -ltr
for dir in package-*; do
	echo " === DEPLOYING ${dir} ==="
    (cd "${dir}"; eval $(cat pkgdata.txt) /deploy.sh)
    echo " === DONE! ==="
done
