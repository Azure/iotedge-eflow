# Copyright (C) 2021 scalers.ai

WELD_POROSITY_MODEL=/models/weld_porosity/FP32/weld-porosity-detection-0001.xml

runPipeline() {
gst-launch-1.0 \
    rtspsrc location=$INPUT ! decodebin  ! videoconvert ! video/x-raw,format=BGRx ! \
    gvapython module=weld_porosity.py class=InferenceTime ! \
    gvainference model=${WELD_POROSITY_MODEL} inference-interval=1  device=$DEVICE ! \
    gvapython  module=weld_porosity.py class=WeldPorosity ! \
    gvametaconvert format=json add-tensor-data=true ! \
    gvametapublish method=mqtt address=MQTTBroker:1883 topic=weld

return 
}

until runPipeline;
do
    echo 'Restarting pipeline'
    sleep 1
done