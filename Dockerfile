FROM nvidia/cuda:10.2-devel-ubuntu16.04

RUN apt-get update && apt-get remove -y x264 libx264-dev
RUN apt-get update && apt-get upgrade -y 

# Get apt dependencies
RUN apt-get update && apt-get install -y  \
    sudo clang-format wget apt-utils \
    build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget \
    build-essential checkinstall cmake pkg-config yasm git \
    gfortran libjpeg8-dev libjasper-dev libpng12-dev libtiff5-dev libavcodec-dev libavformat-dev \
    libswscale-dev libdc1394-22-dev libxine2-dev libv4l-dev libgstreamer0.10-dev \
    libgstreamer-plugins-base0.10-dev qt5-default libgtk2.0-dev libtbb-dev libatlas-base-dev \
    libfaac-dev libmp3lame-dev libtheora-dev libvorbis-dev libxvidcore-dev libopencore-amrnb-dev \
    libopencore-amrwb-dev x264 v4l-utils libprotobuf-dev protobuf-compiler libgoogle-glog-dev \
    libgflags-dev libgphoto2-dev libeigen3-dev libhdf5-dev doxygen software-properties-common

# Install Python 3.7.4
RUN add-apt-repository -y ppa:deadsnakes/ppa &&\
    apt-get update && apt-get install -y python3.7

RUN rm -rf /var/lib/apt/lists/* 

# Install Opencv 4.1.2 + contrib + cuda
RUN wget https://github.com/opencv/opencv/archive/4.1.2.tar.gz -O /opt/core.tar.gz &&\
    wget https://github.com/opencv/opencv_contrib/archive/4.1.2.tar.gz -O opt/contrib.tar.gz &&\
    cd /opt && tar -xvf core.tar.gz &&\
    cd /opt && tar -xvf contrib.tar.gz

RUN cd /opt && mkdir -p opencv-4.1.2/build &&\
    cd /opt/opencv-4.1.2/build &&\
    cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D WITH_CUDA=ON \
    -D WITH_TBB=ON \
    -D WITH_V4L=ON \
    -D WITH_QT=ON \
    -D WITH_OPENGL=ON \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D BUILD_JAVA=OFF \
    -D CUDA_NVCC_FLAGS="--expt-relaxed-constexpr" \
    -D OPENCV_EXTRA_MODULES_PATH="../../opencv_contrib-4.1.2/modules" \
    ..

RUN cd /opt/opencv-4.1.2/build && make -j 4 && make -j 4 install
