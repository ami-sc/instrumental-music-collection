#!/bin/bash

# Variables for color print.
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
END="\e[0m"

# Get command line arguments.
while getopts i:o: flag
do
    case "${flag}" in
      i) input_metadata=${OPTARG};;
      o) output_dir=${OPTARG};;
      *) printf "%b\n" "${RED}[ ! ]${END} Invalid Argument"
         exit 1;;
    esac
done

{
    # Skip header line of .tsv.
    read -r

    while IFS=$'\t' read -r code extension track title artist album year disc artwork
    do
        file_path="${output_dir}/${code}.txt"

        printf "%b: %s\r" "${CYAN}[ i ]${END} Processing file" "${code}${extension}"

        # Create metadata file.
        touch "${file_path}"

        # Write metadata to file.
        {
            printf "%s\t" "${extension}"
            printf "%s\t" "${track}"
            printf "%s\t" "${title}"
            printf "%s\t" "${artist}"
            printf "%s\t" "${album}"
            printf "%s\t" "${year}"
            printf "%s\t" "${disc}"
            printf "%s" "${artwork}"
        } >> "${file_path}"

        printf "%b: %s\n" "${GREEN}[ ✓ ]${END} Generated metadata file for" "${code}${extension}"
    done
} < "${input_metadata}"
