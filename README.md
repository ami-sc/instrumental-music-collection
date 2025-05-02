<div align="center">
    <img src="extra/icon.svg" alt="NCH Logo" width="64" height="64">
    <div>
        <br>
        <code>201.001</code>
    </div>
    <h1 align="center">Instrumental Music Collection</h1>
</div>

<br>

<div align="center">
    <p>
        <a align="center" href="https://git.ami.sc/ami/instrumental-music-collection">
            <img height="16" width="16" src="https://cdn.simpleicons.org/gitea/00B8FF/00B8FF"/>
            &nbsp;Starlane
        </a>
        &emsp;
        <a align="center" href="https://github.com/ami-sc/instrumental-music-collection">
            <img height="16" width="16" src="https://cdn.simpleicons.org/github/00B8FF/00B8FF"/>
            &nbsp;GitHub
        </a>
    </p>
</div>

<img height="4" width="100%" src="extra/gradient.png"/>

## Description

A collection of scripts to encode and tag my personal instrumental music collection.

## Requirements

System dependencies:

- `make`
- `rsync`
- `ffmpeg`
- `metaflac`

This project is managed through a `conda` environment. To install the required dependencies, run the following:

```bash
conda env create -f environment.yml
```

## Running

First, activate the `conda` environment:

```bash
conda activate IMS
```

Then, run the processing pipeline with:

```bash
make all -j $(nproc) \   
    SSH_LOCATION=user@location \
    CELLAR_BOTTLE=/path/to/bottle \
    PROJECT_ID=201.001 \
    INSTALL_DIR=/path/to/install/dir
```

The finalized collection will be installed to the specified `INSTALL_DIR`.

To clean up the working directories, run:

```bash
make clean
```
