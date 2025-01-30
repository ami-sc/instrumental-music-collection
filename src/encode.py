import sys
import argparse
import subprocess
import pandas as pd


def run_cmd(cmd):
    try:
        subprocess.run(cmd, check = True,
                       stdout = subprocess.DEVNULL,
                       stderr = subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        sys.exit(1)


def encode():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-t", "--track_file",
        type = str,
        help = "Path to input track file.",
        required = True)
    parser.add_argument(
        "-id", "--identifier",
        type = str,
        help = "Identifier code for the given track.",
        required = True)
    parser.add_argument(
        "-m", "--metadata_file",
        type=str,
        help="Path to .csv metadata file.",
        required=True)
    parser.add_argument(
        "-a", "--artwork_dir",
        type=str,
        help="Path to directory containing artwork files.",
        required=True)
    parser.add_argument(
        "-o", "--output_file",
        type=str,
        help="Path to .csv file to store individual sample metadata.",
        required=True)
    args = parser.parse_args()

    metadata_df = pd.read_csv(args.metadata_file)
    track_metadata = metadata_df[metadata_df["Code"] == args.identifier]

    if track_metadata["File Extension"].item() != ".flac":
        cmd = [
            "ffmpeg",
            "-i", args.track_file,
            "-vn",
            "-c:a", "flac",
            args.output_file
        ]
    else:
        cmd = [
            "cp",
            args.track_file,
            args.output_file
        ]

    run_cmd(cmd)

    # Remove any existing metadata.
    cmd = [
        "metaflac",
        "--remove-all-tags",
        args.output_file
    ]
    run_cmd(cmd)

    # Remove any existing album artwork.
    cmd = [
        "metaflac",
        "--remove",
        "--block-type=PICTURE,PADDING",
        "--dont-use-padding",
        args.output_file
    ]
    run_cmd(cmd)

    cmd = [
        "metaflac",
        "--remove-tag=COVERART",
        args.output_file
    ]
    run_cmd(cmd)

    # Write the new metadata.
    cmd = [
        "metaflac",
        f"--set-tag=ALBUM={track_metadata['Album'].item()}",
        f"--set-tag=ARTIST={track_metadata['Artist'].item()}",
        f"--set-tag=TITLE={track_metadata['Title'].item()}",
        f"--set-tag=TRACKNUMBER={track_metadata['Track'].item()}",
        f"--set-tag=DATE={track_metadata['Year'].item()}",
        f"--set-tag=DISCNUMBER={track_metadata['Disc'].item()}",
        f"--import-picture-from={args.artwork_dir}/{track_metadata['Artwork File'].item()}",
        args.output_file
    ]
    run_cmd(cmd)


if __name__ == "__main__":
    encode()
