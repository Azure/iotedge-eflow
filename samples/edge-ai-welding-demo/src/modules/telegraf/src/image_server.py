"""
Copyright (C) 2021 scalers.ai
Image server based on flask to serve images for dashboard

version: 1.0
"""
import os
import time
from contextlib import contextmanager, redirect_stderr, redirect_stdout
from os import devnull

import cv2
from flask import Flask, Response, request

from mqtt_sub import MQTTSub

app = Flask(__name__)
MQTT_IP = os.environ['MQTT_IP']
mqtt = MQTTSub(MQTT_IP, False)


@contextmanager
def suppress_stdout_stderr():
    """A context manager that redirects stdout and stderr to devnull"""
    with open(devnull, 'w') as fnull:
        with redirect_stderr(fnull) as err, redirect_stdout(fnull) as out:
            yield (err, out)


def gen_live(stream_id: str) -> bytes:
    """
    Generate live streams for an input stream ID

    :params stream_id: Stream ID of the pipeline

    :returns bytes
    """
    while True:
        try:
            time.sleep(0.01)
            live = mqtt.stream_data[stream_id]['live']
        except KeyError:
            print("Stream ID not found")
            continue

        ret, buffer = cv2.imencode('.jpg', live)
        if ret:
            frame = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')


@app.route('/feed')
def live_feed():
    """Serve video feed on path /feed"""
    stream_id = request.args.get('stream', default="100", type=str)
    return Response(gen_live(stream_id), mimetype='multipart/x-mixed-replace; boundary=frame')


def main():
    """Main method"""
    try:
        print("Starting Video feed server")
        app.run(host='0.0.0.0', port=5100, debug=True)
    except Exception as exc:
        error_msg = ("Exception while starting video feed server. "
                     f"{type(exc).__name__}: {exc}")
        print(error_msg)


if __name__ == '__main__':
    with suppress_stdout_stderr():
        main()
