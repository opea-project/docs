#!/bin/bash

pwd
cd scripts

#add "f" to force create env
bash setup_env.sh $1
cd ../..

ENV_NAME=env_sphinx
pwd
source $ENV_NAME/bin/activate

#clone repos
for repo_name in GenAIComps GenAIEval GenAIExamples GenAIInfra; do
  echo "prepare for $repo_name"

  if [[ "$1" == "f" ]]; then
    echo "force to clone rep ${repo_name}"
    rm -rf ${repo_name}
  fi

  if [ ! -d ${repo_name} ]; then
    URL=https://github.com/opea-project/${repo_name}.git
    echo "clone $URL"
    git clone $URL
  else
    echo "found existed repo folder ${repo_name}, skip to clone"
  fi
done

echo "Build HTML"
cd docs
make clean
make html

echo "Build online doc done!"