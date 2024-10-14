#!/bin/bash

sudo apt install git graphviz -y

ENV_NAME=env_sphinx
deactivate

pwd
cd ../..

if [[ "$1" == "f" ]]; then
    echo "force to create env by rm existed env folder $ENV_NAME"
    rm -rf $ENV_NAME
fi

if [ -d $ENV_NAME ]; then
    echo "found existed env $ENV_NAME, skip create. Use "f" to force create"
    exit 0
fi


python -m venv $ENV_NAME
source $ENV_NAME/bin/activate
pip install --upgrade pip
pip install -r docs/scripts/requirements.txt

echo "build env $ENV_NAME is done"
exit 0
