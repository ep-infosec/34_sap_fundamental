#! /bin/bash

set -e

git config --global user.email "fundamental@sap.com"
git config --global user.name "fundamental-bot"

# delete temp branch
git push "https://$GH_TOKEN@github.com/$TRAVIS_REPO_SLUG" ":$TRAVIS_BRANCH" > /dev/null 2>&1;

std_ver=$(npm run std-version)
release_tag=$(echo "$std_ver" | grep "tagging release" | awk '{print $4}')

# some versions of standard-version are not echoing the "v" prefix on the "tagging release" line
# if it doesn't exist, let's add it so creating a release works properly
if [[ ${release_tag::1} != "v" ]]; then
    release_tag="v${release_tag}";
fi

echo "$std_ver"

git push --follow-tags "https://$GH_TOKEN@github.com/$TRAVIS_REPO_SLUG" main > /dev/null 2>&1;

# build dist and less folders
npm run build:prod

npm publish

# run this after publish to make sure GitHub finishes updating from the push
npm run release:create -- --repo $TRAVIS_REPO_SLUG --tag $release_tag --branch main

npm run docs:prod
npm run deploy -- --repo "https://$GH_TOKEN@github.com/$TRAVIS_REPO_SLUG"
