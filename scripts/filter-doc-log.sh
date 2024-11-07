#!/bin/bash
# Copyright (C) 2019-2024 Intel Corporation.
# SPDX-License-Identifier: Apache-2.0

# run the filter-known-issues.py script to remove "expected" warning
# messages from the output of the document build process and write
# the filtered output to stdout
#
# Only argument is the name of the log file saved by the build.
echo "entry filter doc log"
KI_SCRIPT=scripts/filter-known-issues.py
CONFIG_DIR=known-issues/doc

LOG_FILE=$1
BUILDDIR=$(dirname $LOG_FILE)

if [ -z "${LOG_FILE}" ]; then
        echo "Error in $0: missing input parameter <logfile>"
        exit 1
fi

# When running in background, detached from terminal jobs, tput will
# fail; we usually can tell because there is no TERM env variable.
if [ -z "${TERM:-}" -o "${TERM:-}" = dumb ]; then
    TPUT="true"
    red=''
    green=''
else
    TPUT="tput"
    red='\E[31m'
    green='\e[32m'
fi

if [ -s "${LOG_FILE}" ]; then
   echo "run $KI_SCRIPT"
   ls -la
   ls -la known-issues
   python $KI_SCRIPT --config-dir ${CONFIG_DIR} ${LOG_FILE} -o ${BUILDDIR}/doc.warnings
   if [ -s ${BUILDDIR}/doc.warnings ]; then
	   echo
	   echo -e "${red}New errors/warnings found, please fix them:"
	   echo -e "=============================================="
	   $TPUT sgr0
	   echo
	   cat ${BUILDDIR}/doc.warnings
	   echo
	   exit 2
   else
	   echo -e "${green}No new errors/warnings."
	   $TPUT sgr0
   fi

else
   echo "Error in $0: logfile \"${LOG_FILE}\" not found."
   exit 3
fi
