#!/bin/bash
set -e
ls -ltr
for dir in package-*; do
  echo "::group::DEPLOYING ${dir}"
  (cd "${dir}"; eval $(cat pkgdata.txt) /deploy.sh)
  echo "::endgroup::"
done

DEPLOYED_PACKAGES=$(echo package-*)
echo "DEPLOYED_PACKAGES: ${DEPLOYED_PACKAGES}"
echo ::set-output name=deployed_packages::$DEPLOYED_PACKAGES
