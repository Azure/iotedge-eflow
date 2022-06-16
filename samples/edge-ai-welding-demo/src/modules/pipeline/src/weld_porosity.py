# Copyright (C) 2021 scalers.ai
"""
Weld Porosity Recognition script
Serving DL Streamer extension

version: 1.0
"""
import base64
import json
import time

import cv2
import numpy as np
from gstgva import VideoFrame
from opcua import Client
import os


class InferenceTime:
    """
    Class to add the inference start time to frame messages
    """
    def process_frame(self, frame: VideoFrame):
        """
        method to store the model inference start time

        :param frame: gstgva.VideoFrame object

        :returns bool
        """
        frame.add_message(json.dumps({"time": str(time.time())}))
        return True

class WeldPorosity:
    """Weld porosity detection class"""
    def __init__(self) -> None:
        self.labels = [
            "no weld",
            "normal weld",
            "porosity"
        ]
        self.client = self.connect_opcua()

    def connect_opcua(self):
        """Connect to opcua server

        :returns client: opcua client object
        """
        opcua_url = "opc.tcp://opcua:4840"
        client = Client(opcua_url)
        client.connect()

        return client

    def get_target_hardware(self):
        """Read target hardware of the pipeline from
        TARGET environment variable
        """
        try:
            target = os.environ['TARGET_HARDWARE']
        except Exception:
            target = 'CPU'

        return target


    def set_opcua_values(self, weld_class: int, prob: float, fps: float) -> None:
        """Set inference results to opcua variables

        :param weld_class: Weld Class detected
        :param prob: Probabilty of the class detected
        :param fps: Frame per second of the model

        :returns None
        """
        # get variables
        WeldClass = self.client.get_node("ns=2;i=2")
        Probability = self.client.get_node("ns=2;i=3")
        FPS = self.client.get_node("ns=2;i=4")

        # set values to the variables
        WeldClass.set_value(weld_class)
        Probability.set_value(prob)
        FPS.set_value(fps)

    def encode_frame(self, image) -> str:
        """Encode the frame after reshaping

        :param image: np.ndarray

        :return : str
        """
        width = 720
        height = 550
        resized_image = cv2.resize(
            image, (width, height),
            interpolation=cv2.INTER_AREA
        )
        _, buffer = cv2.imencode('.jpg', resized_image)
        return base64.b64encode(buffer).decode()

    def softmax(self, values, axis=None):
        """Normalizes logits to get confidence values along specified axis"""
        exp = np.exp(values)
        return exp / np.sum(exp, axis=axis)

    def process_frame(self, frame: VideoFrame) -> bool:
        """
        process_frame method to be called by gvapython on every frame

        :param frame: gstgva.VideoFrame object

        :returns bool
        """
        # calculate model fps by getting inference start time
        data = json.loads(frame.messages()[0])['time']
        inference_time = time.time() - float(data)
        fps = 1 / inference_time
        for message in frame.messages():
            frame.remove_message(message)

        target = self.get_target_hardware()

        with frame.data() as mat:
            for tensor in frame.tensors():
                data = tensor.data()
                probs = self.softmax(data - np.max(data))
                top_ind = np.argsort(data)[::-1][:1][0]
                label_prob = probs[top_ind]*100

                # set opcua variables
                self.set_opcua_values(int(top_ind), label_prob, fps)

                infer_metadata = {
                    "stream": "100",
                    "label": int(top_ind),
                    "prob": label_prob,
                    "fps": fps,
                    "image": self.encode_frame(mat),
                    'target': target
                }

                frame.add_message(json.dumps(infer_metadata))

        return True
