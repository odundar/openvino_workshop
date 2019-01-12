
# The default path for the job is your home directory, so we change directory to where the files are.
cd $PBS_O_WORKDIR

# Object detection script writes output to a file inside a directory. We make sure that this directory exists.
#  The output directory is the first argument of the bash script


if [ "$2" = "HETERO:FPGA,CPU" ]; then
    source /opt/intel/computer_vision_sdk/bin/setup_hddl.sh
    aocl program acl0 /opt/intel/computer_vision_sdk_2018.4.420/bitstreams/a10_vision_design_bitstreams/4-0_PL1_FP11_MobileNet_ResNet_VGG_Clamp.aocx
fi
    
# Running the object detection code
SAMPLEPATH=$PBS_O_WORKDIR
python3 object_detection_demo_ssd_async.py -m ${SAMPLEPATH}/models/mobilenet-ssd/$3/mobilenet-ssd.xml \
                                           -i /data/reference-sample-data/object-detection-python/cars_1900.mp4 \
                                           -o $1 \
                                           -d $2 \
                                           -l /data/reference-sample-data/extension/libcpu_extension.so

g++ -std=c++14 ROI_writer.cpp -o ROI_writer  -lopencv_core -lopencv_videoio -lopencv_imgproc -lopencv_highgui  -fopenmp -I/opt/intel/computer_vision_sdk/opencv/include/ -L/opt/intel/computer_vision_sdk/opencv/lib/

#$skip_frame (1->no-skip, 2->skip 1 frame)
#$resolution (float) 1.0, 0.75, 0.5
#resolution 0.75: the output resolution equals to 75% of the input resolution
#resolution 1.0: the output resolution equals to the input video resolution
#resolution 0.5: the output resolution equals to 50% of the input resolution
SKIPFRAME=1
RESOLUTION=0.5
./ROI_writer "/data/reference-sample-data/object-detection-python/cars_1900.mp4" $1 $SKIPFRAME $RESOLUTION
