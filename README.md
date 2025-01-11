# Instrumental Music Collection

## Description

This repository contains scripts to automate encoding and metadata management of instrumental tracks.

## Requirements

The project depends on the following:

- `ffmpeg`
- `metaflac`

## Running

To encode all files to `.flac` and write metadata, run:

```sh
make all -j 14
```

To install the encoded files to a target location, run:

```sh
make install INSTALL_DIR=/path/to/dir

```
