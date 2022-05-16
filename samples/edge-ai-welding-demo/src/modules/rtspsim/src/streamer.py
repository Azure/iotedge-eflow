# Copyright (C) 2021 scalers.ai

import glob
import os
import subprocess
import cv2
import time


def run_streams():
    """
    Stream ffmpeg rtsp streams for all the mp4 files in a directory
    The streams will be ran on a infinite loop
    """
    media_dir = "/input/"
    pipelines = {}

    # create streaming pipeline for all videos in input folder
    os.chdir(media_dir)
    for media in glob.glob("*.mp4"):
        media_path = os.path.join(media_dir, media)
        pipelines[media] = (["ffmpeg", "-re", "-stream_loop", "-1", "-i", media_path, "-c",
                             "copy", "-f", "rtsp", f"rtsp://0.0.0.0:8554/{media}"])

    # start all rtsp streams for pipelines created
    for media in pipelines:
        try:
            subprocess.run(pipelines[media])
        except Exception as err:
            print(f"Exception {err} \n\n Exiting...")
            exit(1)

    # use opencv to check for closed rtsp streams
    # if any stream found closes, restart the same
    while True:
        for media in pipelines:
            rtsp_url = f"rtsp://localhost:8554/{media}"
            cap = cv2.VideoCapture(rtsp_url)
            if (not cap.isOpened()):
                print(f"[NO STREAM]: {media}")
                print(f"[INFO] Restarting stream for {media}")
                subprocess.run(pipelines[media])
            else:
                print(f"[HEALTHY STREAM] {media}")
            cap.release()
        time.sleep(5)


if __name__ == "__main__":
    run_streams()
