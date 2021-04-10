#!/bin/bash
set -e

# What are we deploying
case "${TARGET}" in
"source") 
	PKGTYPE="src"
	;;
"win"*) 
	PKGTYPE="win"
	;;
"mac"*) 
	PKGTYPE="mac"
	;;
*)
	echo "Unexpected target: $TARGET"
	exit 1
	;;
esac
if [ -f "$FILE" ]; then
	MD5SUM=$(openssl dgst -md5 $FILE | awk '{print $2}')
	echo "Deploying: $FILE with md5: $MD5SUM"
else
	echo "ERROR: file $FILE not found!"
	exit 1
fi

curl -vL --upload-file "${FILE}" --fail -u "${CRANLIKEPWD}" \
	-H "Builder-Upstream: ${REPO_URL}" \
	-H "Builder-Date: $(date +'%s')" \
	-H "Builder-Commit: ${REPO_COMMIT}" \
	-H "Builder-Registered: ${REPO_REGISTERED}" \
	-H "Builder-Timestamp: ${COMMIT_TIMESTAMP}" \
	-H "Builder-MaintainerLogin: ${MAINTAINER_LOGIN}" \
	-H "Builder-Distro: ${DISTRO}" \
	-H "Builder-Host: GitHub-Actions" \
	-H "Builder-Status: ${JOB_STATUS}" \
	-H "Builder-Vignettes: ${VIGNETTES}" \
	-H "Builder-Sysdeps: ${SYSDEPS}" \
	-H "Builder-Pkglogo: ${PKGLOGO}" \
	-H "Builder-Url: https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}" \
  -H 'Expect:' \
	"${CRANLIKEURL}/${PACKAGE}/${VERSION}/${PKGTYPE}/${MD5SUM}"

echo " === Complete! === "
