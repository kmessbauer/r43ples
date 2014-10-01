#!/bin/bash

# This scripts updates the javadoc and pushes all changes together 
# with README.md to gh-pages in order to update th website
ant javadoc
git clone -b gh-pages --depth=10 https://$GITAUTH@github.com/plt-tud/r43ples
rm -rf r43ples/javadoc
cp -r javadoc r43ples/javadoc
echo -e '---\nlayout: index\n---\n' > r43ples/index.md
cat README.md >> r43ples/index.md
cd r43ples/javadoc
git config --local user.email "r43ples-travis-ci@users.noreply.github.com"
git config --local user.name "r43ples travis-ci"
git config --local push.default simple
git add *
git commit -am "javadoc updated by travis-ci"
git push https://$GITAUTH@github.com/plt-tud/r43ples
cd ..
rm -rf r43ples
