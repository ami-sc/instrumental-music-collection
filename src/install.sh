#!/bin/bash

# Variables for color print.
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
END="\e[0m"

# Get command line arguments.
while getopts r:m:i: flag
do
    case "${flag}" in
      r) encode_dir=${OPTARG};;
      m) metadata_dir=${OPTARG};;
      i) install_dir=${OPTARG};;
      *) printf "%b\n" "${RED}[ ! ]${END} Invalid Argument"
         exit 1;;
    esac
done

# Create install directory (if it does not exist).
mkdir -p "${install_dir}"

for file in "${metadata_dir}"/*.txt
do
    # Read file metadata.
    IFS=$'\t' read -r extension track title artist album year disc artwork < "${file}"

    # Get filename without extension.
    filename=$(basename "${file}" ".txt")

    # Replace any '/' with '-' in the song title.
    title="${title//\//-}"

    # Add leading zeroes to disc number.
    disc_num=$(printf "%02d" "${disc}")

    # Add leading zeroes to track number.
    track_num=$(printf "%02d" "${track}")

    # Create album directory (if it does not exist).
    mkdir -p "${install_dir}/${album}"

    # Copy file to installation directory and rename.
    cp "${encode_dir}/${filename}.flac" \
        "${install_dir}/${album}/${disc_num}-${track_num} - ${title}.flac"

    printf "%b: %s\n" "${GREEN}[ ✓ ]${END} Succesfully installed file" "${filename}"
done
