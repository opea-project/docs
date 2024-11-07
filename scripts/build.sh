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
for repo_name in docs GenAIComps GenAIEval GenAIExamples GenAIInfra opea-project.github.io; do
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
    echo "repo ${repo_name} exists, skipping cloning"
  fi
done

echo "Build HTML"
cd docs
make -v
make clean
make -i html

retval=$?
echo "result = $retval"
if [ $retval -ne 0 ]; then
  echo "make html is error"
  exit 1
else
  echo "Done"
fi

if [ ! -d _build/html ]; then
  echo "Build online doc is wrong!"
  exit 1
else
  echo "Build online doc done!"
fi

echo "Update github.io"

RELEASE_FOLDER=../opea-project.github.io
BUILDDIR=_build
PUBLISHDIR=${RELEASE_FOLDER}/latest

echo "Clear all content in ${PUBLISHDIR}"
rm -rf ${PUBLISHDIR}/*

echo "Copy html content to ${PUBLISHDIR}"
cp -r ${BUILDDIR}/html/*  ${PUBLISHDIR}
cp scripts/publish-README.md ${PUBLISHDIR}/../README.md
bash scripts/publish-redirect.sh ${PUBLISHDIR}/../index.html latest/index.html
sed 's/<head>/<head>\n  <base href="https:\/\/opea-project.github.io\/latest\/">/' ${BUILDDIR}/html/404.html > ${PUBLISHDIR}/../404.html

echo "Copied html content to ${PUBLISHDIR}"

