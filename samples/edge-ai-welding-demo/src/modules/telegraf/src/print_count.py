#!/usr/bin python3
# Copyright (C) 2021 scalers.ai
# Version: 1.0

import os
import time

from mqtt_sub import MQTTSub


def print_count() -> None:
    """Print inference results by reading data from MQTTSub class"""
    MQTT_IP = os.environ['MQTT_IP']
    mqtt = MQTTSub(MQTT_IP, True)

    while True:
        current_time = int(time.time() * 1000000000)
        stream_data = mqtt.stream_data
        stream = next(iter(stream_data.keys()))

        line = ("weld,stream={} weld_class={},fps={},prob={},target=\"{}\""
                " {} \n").format(
                                stream, stream_data[stream]['label'],
                                stream_data[stream]['fps'],
                                stream_data[stream]['prob'],
                                stream_data[stream]['target'],
                                current_time
                            )
        print(line)
        time.sleep(0.001)


if __name__ == "__main__":
    print_count()
