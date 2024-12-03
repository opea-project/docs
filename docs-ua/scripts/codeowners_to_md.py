#!/usr/bin/env python3
#
# Copyright (c) 2024, Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Convert CODEOWNERS files provided as command line arguments into markdown with
# H2 heading titles followed by a table with path and owners

import sys

def parse_codeowners(file_path):
    codeowners = []

    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            # Skip comments and empty lines
            if not line or line.startswith('#'):
                continue

            parts = line.split()
            if len(parts) >= 2:
                path = parts[0]
                owners = ', '.join(parts[1:])
                codeowners.append((path, owners))

    return codeowners


def convert_to_markdown_table(codeowners, file_name):
    # ./.github/CODEOWNERS ./GenAIComps/.github/CODEOWNERS ./GenAIExamples/.github/CODEOWNERS
    parts = file_name.split('/')
    # if the repo name is missing, it's the docs repo.  Also handle case when
    # CODEOWNERS is in the root of the docs repo instead of in a .github directory.
    repo=parts[1]
    if (repo == '.github'):
        repo="docs"
    elif (repo == "CODEOWNERS"):
        repo="docs"

    table = f"\n## {repo} Repository Code Owners\n\n"
    table += "| Path | Owners |\n"
    table += "|------|--------|\n"

    for path, owners in codeowners:
        table += f"| `{path}` | {owners} |\n"

    return table


def main():
    if len(sys.argv) < 2:
        print("Usage: python codeowners_to_md.py <CODEOWNERS_file1> <CODEOWNERS_file2> ...")
        sys.exit(1)

    markdown_output = ""

    for file_path in sys.argv[1:]:
        try:
            codeowners = parse_codeowners(file_path)
            markdown_table = convert_to_markdown_table(codeowners, file_path)
            markdown_output += markdown_table + "\n"
        except FileNotFoundError:
            print(f"Error: File '{file_path}' not found.")
            sys.exit(1)

    print(markdown_output)


if __name__ == "__main__":
    main()

