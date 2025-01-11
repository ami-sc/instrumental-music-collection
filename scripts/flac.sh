#!/bin/bash

# Variables for color print.
GREEN="\e[32m"
CYAN="\e[36m"
END="\e[0m"

# Get filename and extension.
name="${snakemake_input[0]##*/}"
ext="${name##*.}"

printf "%b: %s\r" "${CYAN}[ i ]${END} Encoding file" "${name}"

if [[ "${ext}" != ".flac" ]]
then
    ffmpeg \
        -i "${snakemake_input[0]}" \
        -vn \
        -c:a flac \
        -hide_banner \
        -loglevel error \
        "${snakemake_output[0]}"
else
    cp "${snakemake_input[0]}" "${snakemake_output[0]}"
fi

printf "%b: %s\r" "${GREEN}[ ✓ ]${END} Finished encoding file" "${name}"
