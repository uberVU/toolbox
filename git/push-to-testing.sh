#!/bin/bash
# Delete and re-fetch testing branch
# Merge current branch into testing and push testing
# Re-checkout current branch

# For ease of use alias this script into your bash or zsh config file 

# Make sure we fail on errors
set -e

CURRENT_BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
git branch -D testing
git fetch origin testing:testing
git checkout testing
echo "Merging in " $CURRENT_BRANCH
git merge $CURRENT_BRANCH

# If for some reasons the merge wasn't successful and our set -e didn't stop 
# the script, let's add one more check to make sure we don't push conflicts
UNMERGED=`git diff --name-only --diff-filter=U`
if [ -z "$UNMERGED" ]; then
    git push origin testing
    git checkout $CURRENT_BRANCH
else
    echo "ABORTING due tue unmerged paths"
fi
