#!/usr/bin python3
# Copyright (C) 2021 scalers.ai
"""
MQTT Subscriber script for receiving data from Weld Porosity recognition
pipeline

version: 1.0
"""
import base64
import json
from json import JSONDecodeError

import cv2
import numpy as np
import paho.mqtt.client as mqtt


class MQTTSub:
    """MQTTSub class to subscribe to weld MQTT topic"""
    def __init__(self, host_ip: str, is_print: bool):
        """Initialize MQTTSub class"""
        self.host_ip = host_ip
        self.is_print = is_print
        self.stream_data = {
            "100": {
                'label': 0,
                'prob': 0,
                'fps': 0,
                'target': 'CPU',
                'live': np.zeros((64, 96, 3), dtype=np.uint8)
            }
        }
        self.connect()

    def decode(self, encoded_img: str) -> np.ndarray:
        """
        Decode base64 encoded images received over mqtt

        :params encoded_img: base64 encoded image

        :returns img: decoded numpy array
        """
        img_original = base64.b64decode(encoded_img)
        img_as_np = np.frombuffer(img_original, dtype=np.uint8)
        img = cv2.imdecode(img_as_np, cv2.IMREAD_COLOR)

        return img

    def on_message(self, client, userdata, msg) -> None:
        """MQTT on_message method"""
        try:
            payload_data = json.loads(msg.payload)
        except JSONDecodeError:
            error_msg = ("Error loading MQTT payload received. Plugin will ",
                         "reload in 20 seconds.")
            exit(1)

        try:
            stream = payload_data['stream']
            if self.is_print:
                weld_class = payload_data['label']
                probability = payload_data['prob']
                fps = payload_data['fps']
                target = payload_data['target']

                self.stream_data = {
                    stream: {
                        'label': weld_class,
                        'prob': probability,
                        'fps': fps,
                        'target': target
                    }
                }
            else:
                org_img = payload_data['image']

        except KeyError:
            error_msg = ("Error loading image/count details from payload. ",
                         "Plugin will reload in 20 seconds")
            exit(1)

        if not self.is_print:
            try:
                live = self.decode(org_img)
            except Exception as exc:
                error_msg = f"{type(exc).__name__}: {exc}"
                print(error_msg)
                exit(1)

            self.stream_data = {
                stream: {
                    'live': live
                }
            }

    def connect(self) -> None:
        """Connect to MQTT Server and run loop in seperate thread"""
        client = mqtt.Client()
        try:
            client.connect(self.host_ip)
        except Exception as exc:
            error_msg = ("Error connectint to MQTT Server. \n"
                         f"{type(exc).__name__}: {exc}")
            print(error_msg)
            exit(1)

        client.subscribe("weld")
        client.on_message = self.on_message
        print("Connected to MQTT Server successfully.")
        # start client loop in seperate thread
        client.loop_start()
