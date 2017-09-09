#!/bin/bash

GIT=`sh /etc/profile; which git`
PLISTBUDDY=/usr/libexec/PlistBuddy

BRANCH=${1:-`${GIT} rev-parse --abbrev-ref HEAD`}
echo "Using branch '${BRANCH}' for counting"

BUILD_NUMBER=$(expr $(${GIT} rev-list ${BRANCH} --count) - $(${GIT} rev-list HEAD..${BRANCH} --count))
echo "Updating build number to ${BUILD_NUMBER} using branch '${BRANCH}'."

COMMIT_SHORT_HASH=$(${GIT} rev-list ${BRANCH} --abbrev-commit | tail -n ${BUILD_NUMBER} | head -n 1)
echo "Commit short hash:${COMMIT_SHORT_HASH}"

${PLISTBUDDY} -c "Set :CFBundleVersion ${BUILD_NUMBER}" "${PROJECT_DIR}/${INFOPLIST_FILE}"
${PLISTBUDDY} -c "Set :CommitShortHash ${COMMIT_SHORT_HASH}" "${PROJECT_DIR}/${INFOPLIST_FILE}"
