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

        # Create album directory (if it does not exist).
        album_dir = os.path.join(args.dir, track_metadata["Album"].item())
        cmd = [
            "mkdir",
            "-p",
            album_dir
        ]
        run_cmd(cmd)

        # Copy song to target directory.
        disc_number = track_metadata["Disc"].item()
        track_number = track_metadata["Track"].item()
        song_title = track_metadata["Title"].item()
        song_title = song_title.replace("/", " - ")

        track_path = os.path.join(
            album_dir,
            f"{disc_number:>02}-{track_number:>02} {song_title}.flac")

        cmd = [
            "cp",
            os.path.join(args.track_dir, track),
            track_path
        ]
        run_cmd(cmd)


if __name__ == "__main__":
    install()
