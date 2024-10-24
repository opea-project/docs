#!/bin/bash

# synch local copy and origin with what's in upstream repo
# assumes there's an origin and upstream remote defined in each of the repos

# optionally, you can give a branch name as a first parameter and it will
# checkout and sync all the repos to that branchname

branch=${1:-main}

for d in GenAIComps GenAIExamples GenAIEval GenAIInfra docs opea-project.github.io ; do
    cd ~/opea-project/"$d"
    echo "====" $d
    git checkout $branch
    git fetch upstream
    git merge upstream/$branch
    git push origin $branch
done
