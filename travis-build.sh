#!/bin/bash
set -e

# This script is meant to run on Travis-CI only
if [ -z "$TRAVIS_BRANCH" ]; then 
  echo "ABORTING: this script runs on Travis-CI only"
  exit 1
fi

# Check essential envs
if [ -z "$GITHUB_TOKEN" ]; then
  echo "ABORTING: env GITHUB_TOKEN is missing"
  exit 1
fi
if [ -z "$GITHUB_OAUTH_TOKEN" ]; then
  echo "ABORTING: env GITHUB_OAUTH_TOKEN is missing"
  exit 1
fi

# verbose logging
set -x

# create a build number
export BUILD_NR="$(date '+%Y%m%d-%H%M%S')"
echo "BUILD_NR=$BUILD_NR"

# run build
#-create build dest
BUILD_DEST=builds/$BUILD_NR
mkdir -p $BUILD_DEST
#-build
VERSION=v$BUILD_NR make shellcheck
VERSION=v$BUILD_NR make sd-image
#-test
VERSION=v$BUILD_NR make test
#-move artifacts to build dest
mv hypriotos-rpi64* $BUILD_DEST/


# deploy to GitHub releases
export GIT_TAG=v$BUILD_NR
export GIT_RELTEXT="Auto-released by [Travis-CI build #$TRAVIS_BUILD_NUMBER](https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID)"
curl -sSL https://github.com/tcnksm/ghr/releases/download/v0.5.4/ghr_v0.5.4_linux_amd64.zip > ghr.zip
unzip ghr.zip
./ghr --version
./ghr --debug -u DieterReuter -b "$GIT_RELTEXT" $GIT_TAG builds/$BUILD_NR/
