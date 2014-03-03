#!/bin/bash
<<COMMENT
	The script deletes branches which are on github but were merged in
	master. If a branch was merged at some point in master but later
	some new commits were added on the branch, the branch will not be
	found as --merged in master branch.
COMMENT

# After fetching, remove any remote-tracking branches which no longer exist
# on the remote.
echo "Fetching branches and removing those deleted upstream."
git fetch -p

# Return a local name branch from a remote one.
# Input: remotes/origin/b/some_branch_name
# Output: b/some_branch_name
local_from_remote() {
	local remote_branch=$1
	local local_branch=`echo $remote_branch | cut -c 16-`
	echo $local_branch
}

# Deletes a given list of branches both locally and upstream.
delete_branches() {
	list_of_branches=$1
	for branch in $list_of_branches; do
		local_branch=`local_from_remote $branch`
		echo -n "[$local_branch] delete branch:"

		# Silent delete branch on local.
		git branch -d $local_branch &> /dev/null
		# Note user the branch was deleted on local if the delete was done
		# successfully.
		if [ $? == 0 ]; then
			echo -n " local"
		fi

		# Delete branch on remote.
		git push origin :$local_branch &> /dev/null
		if [ $? == 0 ]; then
			echo -n " upstream"
		fi

		# New line after each delete.
		echo
	done
}

start_cleanup() {
	# 1. Extract all the remote branches which are merged in master.
	# 2. Get only those for the remote repo (ubervu), some may have many remotes
	#    in .git/config.
	# 3. All branches are indented 3 chars to align with and show the current
	#    branch(with _*_). So we need to remove the first 3 characters from
	#    output. Not-removing the * from the output (the current branch symbol)
	#    expands to all files in current dir.
	# 4. Remove master branch which shows up as
	#    remotes/origin/HEAD -> origin/master.
	# 5. Remove remotes/origin/master from results.
	local remote_merged=`git branch -a --merged origin/master |
                             grep remotes/origin |
                             cut -c 3- |
                             sed '/^remotes\/origin\/HEAD*/d' |
                             grep --invert-match remotes/origin/master`

	# Delete the remote branches which were merged in master.
	echo "Deleting the following branches"
	echo "---------------------------------"
	echo $remote_merged
	echo "---------------------------------"

	while true; do
		read -p "Do you wish to continue? [y/n] " yn
		case $yn in
			[Yy]* ) delete_branches "$remote_merged"; exit;;
			[Nn]* ) exit;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

start_cleanup

# Do another sync by deleting the local branches which no longer exist remote.
echo "Fetching branches and removing those deleted upstream."
git fetch -p
