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
"linux"*)
	PKGTYPE="linux"
	;;
"failure")
	PKGTYPE="failure"
	;;
*)
	echo "Unexpected target: $TARGET"
	exit 1
	;;
esac

if [ "$PKGTYPE" == "failure" ]; then
  echo "Posting a build-failure for $PACKAGE to the package server!"
  echo "MAINTAINERINFO: $MAINTAINERINFO"
	curl --max-time 60 --retry 3 -vL --fail-with-body -u "${CRANLIKEPWD}" \
		-d "Builder-Upstream=${REPO_URL}" \
		-d "Builder-Registered=${REPO_REGISTERED}" \
		-d "Builder-Commit=${COMMITINFO}" \
		-d "Builder-Maintainer=${MAINTAINERINFO}" \
		-d "Builder-Distro=${DISTRO}" \
		-d "Builder-Host=GitHub-Actions" \
		-d "Builder-Url=https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}" \
		"${CRANLIKEURL}/${PACKAGE}/${VERSION}/${PKGTYPE}"
	exit 0;
fi

if [ -f "$FILE" ]; then
	MD5SUM=$(openssl dgst -md5 $FILE | awk '{print $2}')
	echo "Deploying: $FILE with md5: $MD5SUM"
else
	echo "ERROR: file $FILE not found!"
	exit 1
fi

# Add status for binaries to source deploy
if [ "$PKGTYPE" == "src" ]; then
if [ -d "../package-macos-release" ]; then
MACOS_BINARY_STATUS=$(cd ../package-macos-release; (source pkgdata.txt; echo "$JOB_STATUS"))
elif [ "$SKIP_BINARIES" ]; then
MACOS_BINARY_STATUS="skipped"
else
MACOS_BINARY_STATUS="none"
fi
if [ -d "../package-windows-release" ]; then
WINDOWS_BINARY_STATUS=$(cd ../package-windows-release; (source pkgdata.txt; echo "$JOB_STATUS"))
elif [ "$SKIP_BINARIES" ]; then
WINDOWS_BINARY_STATUS="skipped"
else
WINDOWS_BINARY_STATUS="none"
fi
fi

upload_package_file(){
	curl --max-time 60 --retry 3 -L --upload-file "${FILE}" --fail-with-body -u "${CRANLIKEPWD}" \
		-H "Builder-Upstream: ${REPO_URL}" \
		-H "Builder-Registered: ${REPO_REGISTERED}" \
		-H "Builder-Commit: ${COMMITINFO}" \
		-H "Builder-Maintainer: ${MAINTAINERINFO}" \
		-H "Builder-Distro: ${DISTRO}" \
		-H "Builder-Host: GitHub-Actions" \
		-H "Builder-Status: ${JOB_STATUS}" \
		-H "Builder-Pkgdocs: ${PKGDOCS}" \
		-H "Builder-Srconly: ${SKIP_BINARIES}" \
		-H "Builder-Winbinary: ${WINDOWS_BINARY_STATUS}" \
		-H "Builder-Macbinary: ${MACOS_BINARY_STATUS}" \
		-H "Builder-Url: https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}" \
		-H 'Expect:' \
		"${CRANLIKEURL}/${PACKAGE}/${VERSION}/${PKGTYPE}/${MD5SUM}" &&\
  echo " === Complete! === " &&\
  exit 0
}

# Sometimes deploys randomly drop a connection (server restart?)
# Retry 3 times (curl --retry does not always work)
for x in 1 2 3; do
	upload_package_file || echo "Something went wrong. Waiting 10 seconds to retry..."
	sleep 10
done

echo "Package deploy failed"
exit 1
