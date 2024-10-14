#!/usr/bin/env python3
#
# Copyright (c) 2018-2024, Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Show installed versions of doc building tools (per requirements.txt)

import os.path
import sys
import requirements
import subprocess

class color:
   PURPLE = '\033[95m'
   CYAN = '\033[96m'
   DARKCYAN = '\033[36m'
   BLUE = '\033[94m'
   GREEN = '\033[92m'
   YELLOW = '\033[93m'
   RED = '\033[91m'
   BOLD = '\033[1m'
   UNDERLINE = '\033[4m'
   END = '\033[0m'

# Check all requirements listed in requirements.txt and print out version # installed (if any)
reqfile = os.path.join(sys.path[0], "requirements.txt")
print ("doc build tool versions found on your system per " + reqfile + "...\n")

rf = open(reqfile, "r")

for req in requirements.parse(rf):
    try:
        print("  {} version: {}".format(req.name.ljust(25," "), req.specs))
        if len(req.specs) == 0:
            print (color.RED + color.BOLD + "   >>> Warning: Expected version " +
                    req.name + " Python module from scripts/requirements.text." + color.END)
    except:
        print (color.RED + color.BOLD + req.name + " is missing." + color.END +
                " (Hint: install all dependencies with " + color.YELLOW +
                "\"pip3 install --user -r scripts/requirements.txt\"" + color.END + ")")

rf.close()

# Print out the version of relevent packages not installed via pip
# print ("  " + "doxygen".ljust(25," ") + " version: " + subprocess.check_output(["doxygen", "-v"]).decode("utf-8"))
