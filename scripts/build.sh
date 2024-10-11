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
for repo_name in GenAIComps GenAIEval GenAIExamples GenAIInfra opea-project.github.io; do
  echo "prepare for $repo_name"

  if [[ "$1" == "f" ]]; then
    echo "force to clone rep ${repo_name}"
    rm -rf ${repo_name}
  fi

  if [ ! -d ${repo_name} ]; then
    URL=https://github.com/opea-project/${repo_name}.git

    echo "git clone $URL"
    git clone $URL
    retval=$?
    if [ $retval -ne 0 ]; then
      echo "git clone ${repo_name} is wrong, try again!"
      rm -rf ${repo_name}
      exit 1
    fi
    sleep 10
  else
    echo "found existed repo folder ${repo_name}, skip to clone"
  fi
done

echo "Build HTML"
cd docs
make clean
make html
echo "Build online doc done!"

echo "update github.io"

RELEASE_FOLDER=../opea-project.github.io
rm -rf ${RELEASE_FOLDER}
git clone -b main --single-branch https://github.com/opea-project/opea-project.github.io.git ${RELEASE_FOLDER}


BUILDDIR=_build
PUBLISHDIR=${RELEASE_FOLDER}/latest

cp -r ${BUILDDIR}/html/*  ${PUBLISHDIR}
cp scripts/publish-README.md ${PUBLISHDIR}/../README.md
bash scripts/publish-redirect.sh ${PUBLISHDIR}/../index.html latest/index.html
sed 's/<head>/<head>\n  <base href="https:\/\/opea-project.github.io\/latest\/">/' ${BUILDDIR}/html/404.html > ${PUBLISHDIR}/../404.html

echo "CP html to ${PUBLISHDIR}"

