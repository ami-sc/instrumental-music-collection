#!/bin/bash

# Variables for color print.
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
END="\e[0m"

# Get command line arguments.
while getopts i:m:a:o: flag
do
    case "${flag}" in
      i) input_file=${OPTARG};;
      m) input_metadata=${OPTARG};;
      a) artwork_dir=${OPTARG};;
      o) output_file=${OPTARG};;
      *) printf "%b\n" "${RED}[ ! ]${END} Invalid Argument"
         exit 1;;
    esac
done

printf "%b: %s\r" "${CYAN}[ i ]${END} Encoding file" "${input_file}"

# Read file metadata.
IFS=$'\t' read -r extension track title artist album year disc artwork < "${input_metadata}"

if [[ "${extension}" != ".flac" ]]
then
  ffmpeg \
    -i "${input_file}" \
    -vn\
    -c:a flac \
    -hide_banner \
    -loglevel error \
    "${output_file}"
else
  cp "${input_file}" "${output_file}"
fi

# Remove any exsiting metadata.
metaflac \
  --remove-all-tags \
  "${output_file}"

# Remove any album artwork.
metaflac \
  --remove \
  --block-type=PICTURE,PADDING \
  --dont-use-padding \
  "${output_file}"

metaflac \
  --remove-tag=COVERART \
  --dont-use-padding \
  "${output_file}"

# Write new metadata.
metaflac \
  --set-tag=ALBUM="${album}" \
  --set-tag=ARTIST="${artist}" \
  --set-tag=TITLE="${title}" \
  --set-tag=TRACKNUMBER="${track}" \
  --set-tag=DATE="${year}" \
  --set-tag=DISCNUMBER="${disc}" \
  --import-picture-from="${artwork_dir}/${artwork}" \
  "${output_file}"

printf "%b: %s\n" "${GREEN}[ ✓ ]${END} Succesfully encoded file" "${input_file}"
