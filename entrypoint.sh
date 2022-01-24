#!/bin/bash
set -e
ls -lR

trap 'catch $? $LINENO' EXIT
catch() {
  echo "Run URL: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
  if [ "$1" != "0" ]; then
    echo "Error $1 in line $2"
  else
    echo "All done and well"
  fi
}

# Upload source first
mv package-source package-00source

for dir in package-*; do
  echo "::group::DEPLOYING ${dir}"
  (cd "${dir}"; eval $(cat pkgdata.txt) /deploy.sh)
  echo "::endgroup::"
done

mv package-00source package-source

DEPLOYED_PACKAGES=$(echo package-*)
echo "DEPLOYED_PACKAGES: ${DEPLOYED_PACKAGES}"
echo ::set-output name=deployed_packages::$DEPLOYED_PACKAGES

# Deploy docs
# if [ -d "docs-website" ]; then
#   echo "Found docs-website"
#   cd docs-website
#   ls -ltr
#   unzip docs.zip
#   rm docs.zip
#   cat */info.json
# fi

exit 0