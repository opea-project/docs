#!/bin/bash

if [[ $# < 1 ]]; then
  echo "Miss parameter"
  echo "$0 [version]"
  echo "   like: 1.2, which is defined in html_context.versions of conf.py"
  echo ""
  echo "How to build online doc for history release?"
  echo ""
  echo "  Prepare: add tag in all repos with format 'v*.*', like v1.2"
  echo ""
  echo "  1. Add history release version (like 1.2) in html_context.versions of conf.py."
  echo "  2. Execute this script with release version (like $0 1.2). Build the history release document and output to release folder, like 1.2."
  echo "  3. Execute scripts\build.sh. Update the 'latest' to add new release link in 'Document Versions'."
  echo "  4. Git push the content of opea-project.github.io."
  exit 1
fi

version=$1
TAG="v${version}"

echo "TAG=${TAG}"
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
  cd ${repo_name}
  echo "checkout ${TAG} in ${repo_name}"
  pwd
  git checkout ${TAG}
  cd ..
done

echo "Build HTML"
cd docs
make clean
make DOC_TAG=release RELEASE=${version} html
#make DOC_TAG=release RELEASE=${version} publish
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
PUBLISHDIR=${RELEASE_FOLDER}/${version}

echo "Clear all content in ${PUBLISHDIR}"

mkdir -p ${PUBLISHDIR}
rm -rf ${PUBLISHDIR}/*
echo "Copy html content to ${PUBLISHDIR}"
cp -r ${BUILDDIR}/html/*  ${PUBLISHDIR}

echo "Copied html content to ${PUBLISHDIR}"
