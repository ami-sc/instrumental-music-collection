import os
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


def install():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-td", "--track_dir",
        type = str,
        help = "Path to directory with processed track files.",
        required = True)
    parser.add_argument(
        "-m", "--metadata_file",
        type=str,
        help="Path to .csv metadata file.",
        required=True)
    parser.add_argument(
        "-d", "--dir",
        type=str,
        help="Target directory to install files.",
        required=True)
    args = parser.parse_args()

    metadata_df = pd.read_csv(args.metadata_file)
    track_list = os.listdir(args.track_dir)

    for track in track_list:
        track_metadata = metadata_df[metadata_df["Code"] == track.split(".")[0]]

        # Create output directory (if it does not exist).
        cmd = [
            "mkdir",
            "-p",
            args.dir
        ]
        run_cmd(cmd)

        # Copy song to target directory.
        track_number = track_metadata["Track"].item()
        album_title = track_metadata["Album"].item().replace("/", " - ")
        song_title = track_metadata["Title"].item().replace("/", " - ")

        track_path = os.path.join(
            args.dir,
            f"{track_number:>02} {song_title} [From {album_title}].flac")

        cmd = [
            "cp",
            os.path.join(args.track_dir, track),
            track_path
        ]
        run_cmd(cmd)


if __name__ == "__main__":
    install()
