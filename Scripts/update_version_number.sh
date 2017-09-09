#!/bin/bash

GIT=`sh /etc/profile; which git`
PLISTBUDDY=/usr/libexec/PlistBuddy

BRANCH=${1:-`${GIT} rev-parse --abbrev-ref HEAD`}
echo "Using tag from branch '${BRANCH}' for versioning"

VERSION_NUMBER=`${GIT} describe ${BRANCH} --tags --abbrev=0`

REGEX="([0-9\.]*)(.*)"
if [[ $VERSION_NUMBER =~ $REGEX ]]; then
    VERSION_NUMBER=${BASH_REMATCH[1]}
    ADDITIONAL_VERSION_STRING=${BASH_REMATCH[2]}
fi

if [ -z $POSSIBLE_REST ]; then
	echo "Version number: ${VERSION_NUMBER}"
else
	VERSION_NUMBER=${VERSION_NUMBER%?}
	echo "Version number: ${VERSION_NUMBER}"
	echo "Additional Version String: ${ADDITIONAL_VERSION_STRING}"
fi

${PLISTBUDDY} -c "Set :CFBundleShortVersionString ${VERSION_NUMBER}" "${PROJECT_DIR}/${INFOPLIST_FILE}"
${PLISTBUDDY} -c "Set :AdditionalVersionString ${ADDITIONAL_VERSION_STRING}" "${PROJECT_DIR}/${INFOPLIST_FILE}"
