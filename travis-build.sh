#!/bin/bash
set -e

export EXIT_STATUS=0

echo "TRAVIS_TAG          : $TRAVIS_TAG"
echo "TRAVIS_BRANCH       : $TRAVIS_BRANCH"
echo "TRAVIS_PULL_REQUEST : $TRAVIS_PULL_REQUEST"

rm -rf audit-logging/build
rm -rf audit-test/build

echo "**********************"
echo "Building audit-logging"
echo "**********************"

./gradlew :audit-logging:clean || EXIT_STATUS=$?
./gradlew :audit-logging:check || EXIT_STATUS=$?

if [[ $EXIT_STATUS -ne 0 ]]; then
    echo "Check failed"
    exit $EXIT_STATUS
fi

echo "*******************"
echo "Building audit-test"
echo "*******************"

./gradlew :audit-test:clean || EXIT_STATUS=$?
./gradlew :audit-test:check || EXIT_STATUS=$?

if [[ $EXIT_STATUS -ne 0 ]]; then
    echo "Integration tests failed"
    exit $EXIT_STATUS
fi

if [ "${TRAVIS_PULL_REQUEST}" == 'true' ]; then
  echo "*** Stopping further execution, as this is a PR."
  exit $EXIT_STATUS
fi

if [[ -n $TRAVIS_TAG ]] || [[ $TRAVIS_BRANCH == 'master' ]]; then

  echo "*** Publishing archives for branch $TRAVIS_BRANCH"

  if [[ -n $TRAVIS_TAG ]]; then
      echo " *** Publishing to Bintray.."
      ./gradlew audit-logging:bintrayUpload -S || EXIT_STATUS=$?
  else
      echo " *** Publishing to Grails Artifactory, as no release-tag was found."
      ./gradlew audit-logging:publish -S || EXIT_STATUS=$?
  fi

  echo "*** Building docs and publish to gh-pages branch.."
  
  ./gradlew docs --stacktrace || EXIT_STATUS=$?
  
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
  git config --global credential.helper "store --file=~/.git-credentials"
  echo "https://$GH_TOKEN:@github.com" > ~/.git-credentials

  echo " "
  echo "*** Updating gh-pages branch **"
  cd audit-logging/build
  git clone https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git -b gh-pages gh-pages --single-branch > /dev/null
  cd gh-pages

  # prepare index.html
  mv ../docs/index.html ../docs/plugin.html
  mv ../docs/ghpages.html ../docs/index.html


  # If there is a tag present then this becomes the latest
  if [[ -n $TRAVIS_TAG ]]; then
      mkdir -p latest
      cp -r ../docs/. ./latest/
      git add latest/*

      version="$TRAVIS_TAG"
      version=${version:1}
      majorVersion=${version:0:4}
      majorVersion="${majorVersion}x"

      mkdir -p "$version"
      cp -r ../docs/. "./$version/"
      git add "$version/*"

      mkdir -p "$majorVersion"
      cp -r ../docs/. "./$majorVersion/"
      git add "$majorVersion/*"
  else
      # If this is the master branch then update the snapshot docs
      if [[ $TRAVIS_BRANCH == 'master' ]]; then
        mkdir -p snapshot
        cp -r ../docs/. ./snapshot/
        git add snapshot/*
      fi
  fi

  git commit -m "Updating docs for Travis build: https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
  git push origin HEAD
  cd ..
  rm -rf gh-pages
fi
exit $EXIT_STATUS
